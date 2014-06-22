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

add({notice, Group, Datetime, Text}) ->
    Command = "HMSET",
    NoticeUuid = uuid:to_string(uuid:uuid4()),
    Key = ?PREFIX ++ NoticeUuid,

    Author = "default",
    Attributes = ["group", Group, "message", Text, "datetime", Datetime, "author", Author],
    redis:call({send_redis, {Command, Key, Attributes}}),
    NoticesUuid = notices:add({notices, Key}),
    [list_to_binary(NoticeUuid), list_to_binary(NoticesUuid)].

get({notice_uuid, Uuid}) ->
    Command = "HGETALL",

    {
        ok,
        [
            <<"group">>, Group,
            <<"message">>, Message,
            <<"datetime">>, Datetime,
            <<"author">>, Author
        ]
    } = redis:call({send_redis, {Command, ?PREFIX ++ Uuid}}),

    [
        {<<"uuid">>, list_to_binary(Uuid)},
        {<<"group">>, Group},
        {<<"message">>, Message},
        {<<"datetime">>, Datetime},
        {<<"author">>, Author}
    ].

get_all() ->
    {ok, Keys} = redis:call({send_redis, {"KEYS", ?PREFIX ++ "*"}}),
    get_notices_by_keys(Keys).

key({notice_uuid, Uuid}) ->
    ?PREFIX ++ Uuid.

remove({notice_uuid, Uuid}) ->
    {ok, <<"1">>} = redis:call({send_redis, {"DEL", ?PREFIX ++ Uuid}}),
    ok.

get_notices_by_keys([Key | Keys]) ->
        ?PREFIX ++ <<Uuid>> = binary_to_list(Key),
    [?MODULE:get({notice, Uuid}) | ?MODULE:get_notices_by_keys(Keys)];
get_notices_by_keys([]) ->
    [].
