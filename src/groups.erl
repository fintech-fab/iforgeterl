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
    Uuid = uuid:to_string(uuid:uuid4()),
    Key = "group:" ++ Uuid,
    Attributes = [name, Name, author, Author],
    redis:hmset(Key,Attributes),
    Uuid.

add({group, User}, Uuid) ->
    Key = "group:" ++ Uuid ++ ":members",
    Attributes = ["user:"++User],
    {ok, Value} = redis:sadd(Key,Attributes),
    Value.

get({uuid, Uuid}) ->
    KeyGroup = "group:" ++ Uuid,
    groups:get(KeyGroup);

get(KeyGroup) ->
    {ok, Value} = redis:hgetall(KeyGroup),
    Value.

member({uuid, GroupUuid}) ->
    Key = "group:" ++ GroupUuid,
    member(Key);

member(Key) ->
    Members = redis:smembers(Key ++ ":members"),
    member_result(Members).

member_result({ok, Members}) ->
    Members;

member_result([]) ->
    [].

