-module(sign_up).

-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_accepted/2]).
-export([content_types_provided/2]).
-export([sign_up/2]).

% Generic
init(Req0, Opts) ->
	{cowboy_rest, Req0, Opts}.

allowed_methods(Req, State) ->
	{[<<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
  {[
    {{<<"application">>, <<"json">>, []}, sign_up}
  ], Req, State}.

content_types_provided(Req0, Env0) ->
	{[
		{{<<"application">>, <<"json">>, []}, sign_up}
	], Req0, Env0}.

% Specific
sign_up(Req0, Env0) ->
    {ok, User0, _} = utils:read_body(Req0),
    case User0 of
        <<>> -> {true, Req0, Env0};
        _ ->
            io:format("-- ~p -- ~n ~n ", [?MODULE]),
            UserMap = jiffy:decode(User0, [return_maps]),
            NewUser = users_service:create(UserMap),

            { _, { Id } } = maps:find(<<"_id">>, NewUser),
            Jwt = jwerl:sign([{ id, binary_to_list(Id) }]),

            Res0 = jiffy:encode({[
                {token, Jwt},
                {user, UserMap}
            ]}),
            Req1 = cowboy_req:set_resp_body(Res0, Req0),

            {true, Req1, Env0}
    end.

