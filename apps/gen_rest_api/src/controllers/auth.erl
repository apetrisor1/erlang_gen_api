-module(auth).

-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_accepted/2]).
-export([content_types_provided/2]).
-export([register/2]).

% Generic
init(Req0, Opts) ->
	{cowboy_rest, Req0, Opts}.

allowed_methods(Req, State) ->
	{[<<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
  {[
    {{<<"application">>, <<"json">>, []}, register}
  ], Req, State}.

content_types_provided(Req0, Env0) ->
	{[
		{{<<"application">>, <<"json">>, []}, register}
	], Req0, Env0}.

% Specific
register(Req0, Env0) ->
    {ok, User0, _} = utils:read_body(Req0),
    io:format("Jwt is ~p ~n ~n", [User0]),

    case User0 of
        <<>> -> {true, Req0, Env0};
        _ ->
            UserMap = jiffy:decode(User0, [return_maps]),
            User2 = users_service:create(UserMap),

            { _, { Id } } = maps:find(<<"_id">>, User2),
            Jwt = jwerl:sign([{ id, binary_to_list(Id) }]),

            io:format("-- ~p -- ", [?MODULE]),
            io:format("~nJwt is ~p ~n ~n", [Jwt]),

            Res0 = jiffy:encode({[
                {token, Jwt},
                {user, UserMap}
            ]}),
            Req1 = cowboy_req:set_resp_body(Res0, Req0),

            {true, Req1, Env0}
    end.

