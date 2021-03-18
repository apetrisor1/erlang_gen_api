-module(authorization).
-behaviour(cowboy_middleware).

-export([execute/2]).

getMasterKeyProtectedRoutes() ->
    [
        <<"/auth/sign-in">>,
        <<"/auth/sign-up">>
    ].

execute(Req0, Env0) ->
    #{path := Path} = Req0,
    IsMasterKeyProtected = lists:member(Path, getMasterKeyProtectedRoutes()),
    select_strategy(Req0, Env0, IsMasterKeyProtected).

select_strategy(Req0, Env0, true) ->
    master_key(Req0, Env0);
select_strategy(Req0, Env0, false) ->
    jwt(Req0, Env0).

master_key(Req0, Env0) ->
    { bearer, Token } = cowboy_req:parse_header(<<"authorization">>, Req0),
    authenticate_master_key(Token, Req0, Env0).

authenticate_master_key(<<"masterKey">>, Req0, Env0) ->
    { ok, Req0, Env0 };
authenticate_master_key(_, Req0, _) ->
    Req = cowboy_req:reply(401, Req0),
    { stop, Req }.

jwt(Req0, Env0) ->
    { bearer, Token } = cowboy_req:parse_header(<<"authorization">>, Req0),
    Content = jwerl:verify(Token),
    authenticate_jwt_content(Content, Req0, Env0).

authenticate_jwt_content({ ok, UserObject }, Req0, Env0) ->
    #{id := UserId} = UserObject,
    check_user(users_service:find_by_id(UserId), Req0, Env0);
authenticate_jwt_content(_, Req0, _) ->
     Req2 = cowboy_req:reply(401, Req0),
    { stop, Req2 }.

check_user(undefined, Req0, _) ->
     Req2 = cowboy_req:reply(401, Req0),
    { stop, Req2 };
check_user(_, Req0, Env0) ->
    { ok, Req0, Env0 }.
