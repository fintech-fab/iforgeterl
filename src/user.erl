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


add({user, Username, Password}) ->
    Command = "HMSET",
    UserUuid = uuid:to_string(uuid:uuid4()),
    Key = "user:" ++ UserUuid,
    Attributes = ["username", Username, "password", Password],
    redis:call({send_redis, {Command, Key, Attributes}}),
    UserUuid.

%%
%%     UserUuid = uuid:to_string(uuid:uuid4()),
%%     {ok, <<"OK">>} = eredis:q(RedisConnection, ["HMSET", "user:" ++ UserUuid, "username", Username, "email", Email, "phone", Phone]),

set_address({address, Email,Phone}, Uuid) ->
    Command = "HMSET",
    Key = "user:" ++ Uuid ++ ":address",
    redis:call({send_redis, {Command, Key,["email", Email, "phone", Phone]}}),
    Uuid.

get_address(Uuid) ->
    Command = "HGETALL",
    Key = "user:" ++ Uuid ++ ":address",

    {ok, Value} = redis:call({send_redis, {Command, Key}}),
    Value.
%%     {address,Email,Phone}.

get({user, Uuid}) ->
    Command = "HGETALL",
    Key = "user:" ++ Uuid,
    {ok, Value} = redis:call({send_redis, {Command, Key}}),
    Value.

auth(Username, Password) ->
    [
        <<"name">>, _,
        <<"phone">>, _,
        <<"email">>, _,
        <<"pwd">>, Pwd
    ] = ?MODULE:get({user, Username}),

    Hash = getPasswordHash(lists:flatten(Password)),
    PasswordList = binary_to_list(Pwd),

    case PasswordList of
        Hash ->
            true;
        _ ->
            false
    end.

getPasswordHash(Password) ->
    Hash = helpers:md5(Password),
    Hash.
