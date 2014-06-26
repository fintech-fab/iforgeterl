%%%-------------------------------------------------------------------
%%% @author b00ris
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Jun 2014 12:24
%%%-------------------------------------------------------------------
-module(user).
-author("b00ris").

%% API
-compile(export_all).
-compile({no_auto_import, [get/1]}).


add({user, Username, Password}) ->
    Key = "user:" ++ Username,
    Exists = redis:exist(Key),
    case Exists of
        <<49>>->
            [];
         _->
            Attributes = ["username", Username, "password", getPasswordHash(Password)],
            redis:hmset(Key,Attributes),
            Username
    end;

add({guest, Username}) ->
    Key = "user:" ++ Username,
    Exists = redis:exist(Key),
    case Exists of
        <<49>>->
            Username;
        _->
            Attributes = ["username", Username, "password", ""],
            redis:hmset(Key,Attributes),
            Username
    end.

set_address({address, Email, Phone}, Uuid) ->
    Key = "user:" ++ Uuid ++ ":address",
    redis:hmset(Key,["email", Email, "phone", Phone]),
    Uuid;

set_address({email, Email}, Uuid) ->
    Command = "HSET",
    Key = "user:" ++ Uuid ++ ":addresses",
    redis:call({send_redis, {Command, Key, ["email", Email]}}),
    Uuid;

set_address({phone, Phone}, Uuid) ->
    Command = "HSET",
    Key = "user:" ++ Uuid ++ ":addresses",
    redis:call({send_redis, {Command, Key, ["phone", Phone]}}),
    Uuid.

get_address(Uuid) ->
    Key = "user:" ++ Uuid ++ ":address",
    {ok, Value} = redis:hgetall(Key),
    Value.

get({user, Uuid}) ->
    Key = "user:" ++ Uuid,
    {ok, Value} = redis:hgetall(Key),
    Value.

auth(Username, Password) ->

    User = get({user, Username}),
    io:write(User),

    case User of

        [] ->
            false;
        _ ->

            [
                {password, Pwd},
                _
            ] = User,

            Hash = getPasswordHash(lists:flatten(Password)),
            PasswordList = binary_to_list(Pwd),

            case PasswordList of
                Hash ->
                    true;
                _ ->
                    false
            end
    end.

getPasswordHash(Password) ->
    Hash = helpers:md5(Password),
    Hash.
