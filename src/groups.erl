%%%-------------------------------------------------------------------
%%% @author b00ris
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jun 2014 9:18
%%%-------------------------------------------------------------------
-module(groups).
-author("b00ris").

%% API
-compile(export_all).


create({group, Name, Author}) ->
    Command = "HMSET",
    Uuid = uuid:to_string(uuid:uuid4()),
    Key = "group:" ++ Uuid,
    Attributes = [Name, Author],
    redis:call({send_redis, {Command, Key, Attributes}}),
    Uuid.

add({group, User}, Uuid) ->
    Command = "SADD",
    Key = "group:" ++ Uuid ++ ":members",
    Attributes = [User],
    {ok, Value} = redis:call({send_redis, {Command, Key, Attributes}}),
    Value.

get(Uuid) ->
    Command = "HGETALL",
    Key = "group:" ++ Uuid,
    {ok, Value} = redis:call({send_redis, {Command, Key}}),

    Command2 = "SMEMBERS",
    Key2 = "group:" ++ Uuid ++ ":members",
    {ok, Members} = redis:call({send_redis, {Command2, Key2}}),
    [{info, Value}, {members, Members}].

parse(GroupUid, Input) ->

    lists:foreach(fun(H) ->
        Email = string:strip(user:add({guest, H})),


        user:set_address({email, Email}, Email),
        groups:add({group, Email}, GroupUid)
    end, Input),

    Input.