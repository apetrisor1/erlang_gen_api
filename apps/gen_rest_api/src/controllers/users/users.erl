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
init(Req0, Env0) ->
	{ cowboy_rest, Req0, Env0 }.

allowed_methods(Req0, Env0) ->
	{ [<<"GET">>, <<"POST">>, <<"DELETE">>], Req0, Env0 }.

content_types_accepted(Req0, Env0) ->
  { [ { { <<"application">>, <<"json">>, [] }, post_json } ], Req0, Env0 }.

content_types_provided(Req0, Env0) ->
	{ [ { { <<"application">>, <<"json">>, [] }, get_json } ], Req0, Env0 }.

% Placeholders for handlers, TODO
get_json(Req0, Env0) ->
	  { <<"{\"rest\": \"Getting stuff!\"}">>, Req0, Env0 }.

post_json(Req0, Env0) ->
    { true, Req0, Env0 }.

delete_resource(Req0, Env0) ->
    { ok, Req0, Env0 }.
