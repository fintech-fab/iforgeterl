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
    Command = "HMSET",
%%     UserUuid = uuid:to_string(uuid:uuid4()),
    Key = "user:" ++ Username,

    Exists = redis:exist_key(Key),
        io:write("fsdfsdf"),
        io:write(Exists),
    case Exists of
        <<49>>->
            [];
         _->
            Attributes = ["username", Username, "password", getPasswordHash(Password)],
            redis:call({send_redis, {Command, Key, Attributes}}),
            Username
    end.

%%
%%     UserUuid = uuid:to_string(uuid:uuid4()),
%%     {ok, <<"OK">>} = eredis:q(RedisConnection, ["HMSET", "user:" ++ UserUuid, "username", Username, "email", Email, "phone", Phone]),

set_address({address, Email, Phone}, Uuid) ->
    Command = "HMSET",
    Key = "user:" ++ Uuid ++ ":address",
    redis:call({send_redis, {Command, Key, ["email", Email, "phone", Phone]}}),
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

    User = get({user, Username}),

    case User of

        [] ->
            false;
        _ ->

            [
                <<"name">>, _,
                <<"phone">>, _,
                <<"email">>, _,
                <<"pwd">>, Pwd
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
