-module(gen_rest_api_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/rest", rest_handler, []},
			{"/http", http_handler, []}
		]}
	]),
	{ok, _} = cowboy:start_clear(
        http,
        [{port, 8080}],
        #{
            env => #{
				dispatch => Dispatch
			},
            middlewares => [
				cowboy_router,
				masterKey,
				jwt,
				cowboy_handler
			]
        }
    ),
	gen_rest_api_sup:start_link().

stop(_State) ->
	ok = cowboy:stop_listener(http).