% Sets up mongo connection, on app start.
-module(db).

-export([ connect/0, connect/2, insert_one/2 ]).

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
    

insert_one(Object, Collection) ->
    Database = whereis(database),
    io:format("-- ~p -- ", [?MODULE]),
    io:format("~nInserting ~p ~ninto ~p, ~nusing process ~p ~n~n", [Object, Collection, Database]),
    mc_worker_api:insert(Database, Collection, Object).

% TODO Setup supervision, retry connect if failure