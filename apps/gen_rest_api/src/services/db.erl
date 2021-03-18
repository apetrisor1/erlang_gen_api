% Sets up mongo connection, on app start.
-module(db).

-export([
    connect/0,
    connect/2,
    find_by_id/2,
    find_one/2,
    insert_one/2
]).

connect() ->
    connect(localhost, 27017).
connect(_Scheme, _Port) ->
    Database = <<"erlang">>,

    case mc_worker_api:connect ([{database, Database}]) of 
        {ok, Connection} ->
            io:format("MongoDB Connection is OK ~p ~n ~n", [Connection]),
            register(database, Connection),
            {ok, Connection};
        _ ->
            io:format("MongoDB Connection not established.. ~n ~n"),
            exit(1)
    end.

find_by_id(Collection, Id) ->
    io:format("-- MODULE ~p -- ~n ", [?MODULE]),
    io:format("-- SELF ~p -- ~n ", [self()]),
    io:format("~nSearching for ID ~p ~nfrom ~p, ~nusing process ~p ~n~n", [Id, Collection, whereis(database)]),
    mc_worker_api:find_one(whereis(database), Collection, #{ <<"_id">> => { list_to_binary(Id) } }).
    
find_one(Collection, Query) ->
    io:format("-- MODULE ~p -- ~n ", [?MODULE]),
    io:format("-- SELF ~p -- ~n ", [self()]),
    io:format("~nQuerying ~p ~nfrom ~p, ~nusing process ~p ~n~n", [Query, Collection, whereis(database)]),
    mc_worker_api:find_one(whereis(database), Collection, Query).

insert_one(Collection, Object) ->
    io:format("-- MODULE ~p -- ~n ", [?MODULE]),
    io:format("-- SELF ~p -- ~n ", [self()]),
    io:format("~nInserting ~p ~ninto ~p, ~nusing process ~p ~n~n", [Object, Collection, whereis(database)]),
    mc_worker_api:insert(whereis(database), Collection, Object).

% TODO Setup supervision, retry connect if failure