-module(authorization).
-behaviour(cowboy_middleware).

-export([execute/2]).

getMasterKeyProtectedRoutes() ->
    [
        <<"/auth/sign-in">>,
        <<"/auth/sign-up">>
    ].

execute(Req0, Env0) ->
    #{ path := Path } = Req0,
    IsMasterKeyProtected = lists:member(Path, getMasterKeyProtectedRoutes()),
    select_strategy(Req0, Env0, IsMasterKeyProtected).

select_strategy(Req0, Env0, true) ->
    master_key(Req0, Env0);
select_strategy(Req0, Env0, false) ->
    jwt(Req0, Env0).

master_key(Req0, Env0) ->
    { bearer, Token } = cowboy_req:parse_header(<<"authorization">>, Req0),
    authenticate_master_key(Token, Req0, Env0).

jwt(Req0, Env0) ->
    { bearer, Token } = cowboy_req:parse_header(<<"authorization">>, Req0),
    Content = jwerl:verify(Token, hs256, <<"secretKey">>),
    authenticate_jwt(Content, Req0, Env0).

authenticate_master_key(<<"masterKey">>, Req0, Env0) ->
    { ok, Req0, Env0 };
authenticate_master_key(_, Req0, _) ->
    Req = cowboy_req:reply(401, Req0),
    { stop, Req }.

authenticate_jwt({ ok, _ }, Req0, Env0) ->
    { ok, Req0, Env0 };
authenticate_jwt(_, Req0, _) ->
    Req1 = cowboy_req:reply(401, Req0),
    { stop, Req1 }.
