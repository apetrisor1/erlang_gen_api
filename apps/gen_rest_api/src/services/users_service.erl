-module(users_service).

% This service gets called from the user and auth controllers.

% When creating/updating a user, service:
% - validates user input
% - assigns defaults
% - calls db service with the body to be added.

-export([ create/1, find_by_id/1, find_one/1 ]).

create(User0) ->
    % TODO: Validate.
    % Set up a user model that exports its' name, so we may use it as collection name.
    { _, User } = db:insert_one(<<"users">>, User0),
    User.

find_by_id(Id) ->
    db:find_by_id(<<"users">>, Id).

find_one(Query) ->
    db:find_one(<<"users">>, Query).
