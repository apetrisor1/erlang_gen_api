-module(jwt).
-behaviour(cowboy_middleware).

-export([execute/2]).

execute(Req0, Env0) ->
    { bearer, Token } = cowboy_req:parse_header(<<"authorization">>, Req0),
    { ok, Path } = maps:find(path, Req0),

    case Token of
        <<"jwtToken">>              ->
            io:format("jwt OK ~n"),
            { ok, Req0, Env0 };
        _ when Path == <<"/http">>  ->
            io:format("jwt OK ~n"),
            { ok, Req0, Env0 };
        _                           ->
            io:format("jwt NOT OK ~n"),
            Req2 = cowboy_req:reply(401, Req0),
            { stop, Req2 }
    end.
