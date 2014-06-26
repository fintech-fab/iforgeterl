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
        Address = string:strip(H),

        Username = parse_address(Address),
        groups:add({group, Username}, GroupUid)

    end, Input),

    Input.

parse_address(Address) ->
    case re:run(Address, "^[\\d\\s\\+]+$") of
        {match,_} ->
            Phone = re:replace(Address, "[\\s\\+]+", "", [{return, list}, global]),
            Username = user:add({guest, Phone}),
            user:set_address({phone, Phone}, Username),
            Username;
        nomatch ->
            Username = user:add({guest, Address}),
            user:set_address({email, Address}, Username),
            Username
    end.
