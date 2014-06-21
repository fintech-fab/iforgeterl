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
-compile({no_auto_import,[get/1]}).


add({user, Username, Email, Phone}) ->
    Command="HMSET",
    UserUuid = uuid:to_string(uuid:uuid4()),
    Key="user:" ++ UserUuid,
    Attributes = ["username", Username, "email", Email, "phone", Phone],
    redis:call({send_redis,{Command,Key,Attributes}}),
    UserUuid.

%%
%%     UserUuid = uuid:to_string(uuid:uuid4()),
%%     {ok, <<"OK">>} = eredis:q(RedisConnection, ["HMSET", "user:" ++ UserUuid, "username", Username, "email", Email, "phone", Phone]),



get({user, Uuid}) ->
    Command="HGETALL",
    Key="user:" ++ Uuid,
    {ok, Value} = redis:call({send_redis,{Command,Key}}),
%%     io:write(Value),
    Value.

auth(Username, Password) ->
    {ok, RedisConnection} = eredis:start_link(),

    [
        <<"name">>, _,
        <<"phone">>, _,
        <<"email">>, _,
        <<"pwd">>, Pwd
    ] = get({user, Username}),

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
