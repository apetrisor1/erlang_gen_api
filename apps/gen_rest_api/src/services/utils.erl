-module(utils).

-export([
    compare_passwords/2,
    read_body/1    
]).

compare_passwords(P1, P2) ->
    { ok, P2 } =:= bcrypt:hashpw(P1, P2).

% Cowboy specific
read_body(Req0) -> read_body(Req0, <<>>).
read_body(Req0, Acc) ->
    case cowboy_req:read_body(Req0) of
        {ok, Data, Req} -> {ok, << Acc/binary, Data/binary >>, Req};
        {more, Data, Req} -> read_body(Req, << Acc/binary, Data/binary >>)
    end.
