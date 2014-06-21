%%%-------------------------------------------------------------------
%%% @author mart
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. июн 2014 13:01
%%%-------------------------------------------------------------------
-module(notice).
-author("mart").

%% APIa
-export([get/1, add/1, get_all/0, remove/1]).
-define(PREFIX, "notice:").

add({notice,Group, Datetime, Text}) ->
    {ok, RedisConnection} = eredis:start_link(),
    NoticeUuid = uuid:to_string(uuid:uuid4()),
    Author = "default",
    {ok, <<"OK">>} = eredis:q(
        RedisConnection,
        ["HMSET", ?PREFIX ++ NoticeUuid, "group", Group, "message", Text, "datetime", Datetime, "author", Author]
    ),
    list_to_binary(NoticeUuid).

get({notice_uuid, Uuid}) ->
    {ok, RedisConnection} = eredis:start_link(),
    {
        ok,
        [
            <<"group">>, Group,
            <<"message">>, Message,
            <<"datetime">>, Datetime,
            <<"author">>, Author
        ]
    } = eredis:q(RedisConnection, ["HGETALL", ?PREFIX ++ Uuid]),

    [
        {<<"uuid">>, list_to_binary(Uuid)},
        {<<"group">>, Group},
        {<<"message">>, Message},
        {<<"datetime">>, Datetime},
        {<<"author">>, Author}
    ].

get_all() ->
    {ok, RedisConnection} = eredis:start_link(),
    {ok, Keys} = eredis:q(RedisConnection, ["KEYS", ?PREFIX ++ "*"]),
    get_notices_by_keys(Keys).

remove({notice_uuid, Uuid}) ->
    {ok, RedisConnection} = eredis:start_link(),
    {ok, <<"1">>} = eredis:q(RedisConnection, ["DEL", ?PREFIX ++ Uuid]),
    ok.

get_notices_by_keys([Key | Keys]) ->
        ?PREFIX ++ <<Uuid>> = binary_to_list(Key),
    [?MODULE:get({notice, Uuid}) | ?MODULE:get_notices_by_keys(Keys)];
get_notices_by_keys([]) ->
    [].
