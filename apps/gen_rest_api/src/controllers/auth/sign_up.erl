-module(sign_up).

-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_accepted/2]).
-export([content_types_provided/2]).
-export([sign_up/2]).

init(Req0, Opts) ->
	{ cowboy_rest, Req0, Opts }.

allowed_methods(Req0, Env0) ->
	{ [<<"POST">>], Req0, Env0 }.

content_types_accepted(Req0, Env0) ->
    {[
        {{ <<"application">>, <<"json">>, [] }, sign_up }
    ], Req0, Env0}.

content_types_provided(Req0, Env0) ->
	{[
		{{ <<"application">>, <<"json">>, [] }, sign_up }
	], Req0, Env0}.

sign_up(Req0, Env0) ->
    utils:log(),
    { ok, RequestBody, _ } = utils:read_body(Req0),
    sign_up(RequestBody, Req0, Env0).

sign_up(<<>>, Req0, Env0) ->
    % Empty request
    { true, Req0, Env0 };
sign_up(RequestBody, Req0, Env0) ->
    % TODO: Make email and password required
    UserBody     = jiffy:decode(RequestBody, [return_maps]),
    Email        = maps:get(<<"email">>, UserBody),

    Req1 = sign_up(
        UserBody,
        userWithThisEmail,
        users_service:find_one(#{ <<"email">> => Email }),
        Req0,
        Env0    
    ),
    { stop, Req1, Env0 }.

sign_up(UserBody, userWithThisEmail, undefined, Req0, Env0) ->
    allow(UserBody, Req0, Env0);
sign_up(_UserBody, userWithThisEmail, _, Req0, Env0) ->
    reject(Req0, Env0).

allow(UserBody, Req0, _Env0) ->
    NewUser = users_service:create(UserBody),
    Response = jiffy:encode({[
        { token, users_service:get_jwt(NewUser) },
        { user, users_service:view(NewUser) } 
    ]}),
    cowboy_req:reply(200, #{
        <<"content-type">> => <<"application/json">>
    }, Response, Req0).

reject(Req0, _Env0) ->
    ResponseBody = jiffy:encode({[
        { error, <<"Email already exists">> }
    ]}),

    cowboy_req:reply(409, #{
        <<"content-type">> => <<"application/json">>
    }, ResponseBody, Req0).

