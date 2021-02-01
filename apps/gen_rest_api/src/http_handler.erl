-module(http_handler).

-export([init/2]).

init(Req0, Env0) ->
    Req = cowboy_req:reply(
        200,
        #{ <<"content-type">> => <<"text/plain">> },
        <<"Hi World!">>,
        Req0
    ),
    {ok, Req, Env0}.