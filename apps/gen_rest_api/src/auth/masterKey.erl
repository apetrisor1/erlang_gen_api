-module(masterKey).
-behaviour(cowboy_middleware).

-export([execute/2]).

execute(Req0, Env0) ->
	case cowboy_req:parse_header(<<"authorization">>, Req0) of
		{ bearer, <<"masterKey">> } ->
   			io:format("masterKey OK ~n"),
			{ ok, Req0, Env0 };
		_ ->
   			io:format("masterKey NOT OK ~n"),
			Req = cowboy_req:reply(401, Req0),
			{ stop, Req }
	end.
