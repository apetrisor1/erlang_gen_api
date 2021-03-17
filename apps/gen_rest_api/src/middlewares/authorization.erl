-module(authorization).
-behaviour(cowboy_middleware).

-export([execute/2]).

getMasterKeyProtectedRoutes() ->
    [<<"/auth/sign-up">>].

execute(Req0, Env0) ->
    #{path := Path} = Req0,
    IsMasterKeyProtected = lists:member(Path, getMasterKeyProtectedRoutes()),

    case IsMasterKeyProtected of
        true -> master_key(Req0, Env0);
        false -> jwt(Req0, Env0)
    end.


master_key(Req0, Env0) ->
    	case cowboy_req:parse_header(<<"authorization">>, Req0) of
		{ bearer, <<"masterKey">> } ->
			io:format("masterKey OK ~n"),
			{ ok, Req0, Env0 };
		_ ->
			io:format("masterKey NOT OK ~n"),
			Req = cowboy_req:reply(401, Req0),
			{ stop, Req }
	end.


jwt(Req0, Env0) ->
    { bearer, Token } = cowboy_req:parse_header(<<"authorization">>, Req0),
    case jwerl:verify(Token) of
        { ok, UserObject } ->
            #{id := UserId} = UserObject,
            case users_service:find_by_id(UserId) of
                undefined -> 
                    Req2 = cowboy_req:reply(401, Req0),
                    { stop, Req2 };
                _ ->
                    { ok, Req0, Env0 }
            end;
        _ ->
            Req2 = cowboy_req:reply(401, Req0),
            { stop, Req2 }
    end.
