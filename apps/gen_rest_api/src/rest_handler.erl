-module(rest_handler).

-export([init/2]).
-export([content_types_provided/2]).
-export([hello_to_html/2]).
-export([hello_to_json/2]).
-export([hello_to_text/2]).

init(Req0, Opts) ->
    % #{method: Method } = Req0,
	{cowboy_rest, Req0, Opts}.

content_types_provided(Req0, Env0) ->
	{[
		{<<"application/json">>, hello_to_json},
		{<<"text/html">>, hello_to_html},
		{<<"text/plain">>, hello_to_text}
	], Req0, Env0}.

hello_to_html(Req0, Env0) ->
	Body = <<"<html>
              <head>
                  <meta charset=\"utf-8\">
                  <title>REST Hello World!</title>
              </head>
              <body>
                  <p>REST Hello World as HTML!</p>
              </body>
              </html>">>,
	{Body, Req0, Env0}.

hello_to_json(Req0, Env0) ->
	{<<"{\"rest\": \"Hello World!\"}">>, Req0, Env0}.

hello_to_text(Req0, Env0) ->
	{<<"REST Hello World as text!">>, Req0, Env0}.