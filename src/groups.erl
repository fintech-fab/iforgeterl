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

get(Uuid) ->
    KeyGroup = "group:" ++ Uuid,
    {ok, Value} = redis:hgetall(KeyGroup),

    KeyMembers = "group:" ++ Uuid ++ ":members",
    {ok, Members} = redis:smembers(KeyMembers),
    [{info, Value}, {members, Members}].

parse(GroupUid, Input) ->

    lists:foreach(fun(H) ->
        Email = string:strip(user:add({guest, H})),

        user:set_address({email, Email}, Email),
        groups:add({group, Email}, GroupUid)
    end, Input),

    Input.