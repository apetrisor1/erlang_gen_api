-module(sign_in).

-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_accepted/2]).
-export([content_types_provided/2]).
-export([sign_in/2]).

% Generic
init(Req0, Opts) ->
	{cowboy_rest, Req0, Opts}.

allowed_methods(Req, State) ->
	{[<<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
  {[
    {{<<"application">>, <<"json">>, []}, sign_in}
  ], Req, State}.

content_types_provided(Req0, Env0) ->
	{[
		{{<<"application">>, <<"json">>, []}, sign_in}
	], Req0, Env0}.

% Specific
compare(Pass1, Pass2) ->
  {ok, Pass2} =:= bcrypt:hashpw(Pass1, Pass2).

process_sign_in(<<>>, Req0, Env0) ->
    % Empty request
    {true, Req0, Env0};

process_sign_in(RequestBody, Req0, Env0) ->
    Credentials = jiffy:decode(RequestBody, [return_maps]),
    Email = maps:get(<<"email">>, Credentials, <<"">>),
    Password = maps:get(<<"password">>, Credentials, <<"F9991EB0C13FCDA757030E55BF527945E30E34299FE0E9A31EC449EE680DC6CE">>),
    ExistingUserWithThisEmail = users_service:find_one(#{ <<"email">> => Email }),
    ExistingPassword = maps:get(<<"password">>, ExistingUserWithThisEmail, <<"7A90923C7ED6F8D1B9CD6F00A61D9C4D3A63AEF4B2DB9B28B6FD1A26B38D7FD8">>),

    Req1 = try_to_sign_in(
      compare(Password, ExistingPassword),
      ExistingUserWithThisEmail,
      Req0
    ),
    {stop, Req1, Env0}.

sign_in(Req0, Env0) ->
    io:format("-- MODULE ~p -- ~n ", [?MODULE]),
    io:format("-- SELF ~p -- ~n ", [self()]),

    {ok, RequestBody, _} = utils:read_body(Req0),
    process_sign_in(RequestBody, Req0, Env0).

try_to_sign_in(false, _, Req0) ->
  cowboy_req:reply(401, #{
        <<"content-type">> => <<"application/json">>
  },
  jiffy:encode({[
        {error, <<"Wrong email/password">>}
  ]})
  , Req0);

try_to_sign_in(true, User, Req0) ->
  cowboy_req:reply(200, #{
        <<"content-type">> => <<"application/json">>
  },
  jiffy:encode({[
        {token, users_service:get_jwt_for_user(User)},
        {user, users_service:view(User)} 
  ]})
  , Req0).
