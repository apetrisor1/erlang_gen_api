-module(users).
-export([
  init/2,
  allowed_methods/2,
  content_types_accepted/2,
  content_types_provided/2,
  get_json/2,
  post_json/2,
  delete_resource/2
]).

% Generic
init(Req0, Opts) ->
	{cowboy_rest, Req0, Opts}.

allowed_methods(Req0, Env0) ->
	{[<<"GET">>, <<"POST">>, <<"DELETE">>], Req0, Env0}.

content_types_accepted(Req0, Env0) ->
  {[ {{<<"application">>, <<"json">>, []}, post_json} ], Req0, Env0}.

content_types_provided(Req0, Env0) ->
	{[ {{<<"application">>, <<"json">>, []}, get_json}], Req0, Env0}.

get_json(Req0, Env0) ->
    Method = maps:get(method, Req0),
    io:format("Method is ~p ~n ~n", [Method]),
	  {<<"{\"rest\": \"Getting stuff!\"}">>, Req0, Env0}.

post_json(Req0, Env0) ->
    Method = maps:get(method, Req0),
    io:format("Method is ~p ~n ~n", [Method]),
    io:format("Req0 is ~p ~n ~n", [Req0]),
    {true, Req0, Env0}.

delete_resource(Req0, Env0) ->
    Method = maps:get(method, Req0),
    io:format("Method is ~p ~n ~n", [Method]),
    {ok, Req0, Env0}.
