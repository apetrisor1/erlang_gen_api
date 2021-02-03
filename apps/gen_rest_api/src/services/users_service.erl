-module(users_service).

% This service gets called from the user and auth controllers.

% When creating/updating a user, service:
% - validates user input
% - assigns defaults
% - calls db service with the body to be added.

-export([ create/1 ]).

create(User0) ->
    % TODO: Validate.
    % Set up a user model that exports its' name, so we may use it as collection name.
    { _, User } = db:insert_one(User0, <<"users">>),
    User.
