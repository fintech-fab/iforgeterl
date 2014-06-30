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

add({notice, GroupUuid, Datetime, Text}) ->
    NoticeUuid = uuid:to_string(uuid:uuid4()),
    Key = key({notice_uuid, NoticeUuid}),

    Group = groups:get({uuid, GroupUuid}),
    Author = proplists:get_value(author, Group),

    Attributes = [
        "group", "group:" ++ GroupUuid,
        "message", Text,
        "datetime", Datetime,
        "author", Author
    ],
    redis:hmset(Key, Attributes),

    notices:add({notices, Key, Datetime}),

    NoticeUuid.

get({notice_uuid, Uuid}) ->
    Key = key({notice_uuid, Uuid}),
    notice:get(Key);

get(NoticeKey) ->
    {ok, Notice} = redis:hgetall(NoticeKey),
    Notice.

get_all() ->
    Key = "KEYS", ?PREFIX ++ "*",
    {ok, Keys} = redis:keys(Key),
    get_notices_by_keys(Keys).

key({notice_uuid, Uuid}) ->
    ?PREFIX ++ Uuid.

remove({notice_uuid, Uuid}) ->
    Key = ?PREFIX ++ Uuid,
    {ok, <<"1">>} = redis:del(Key),
    ok.

get_notices_by_keys([Key | Keys]) ->
        ?PREFIX ++ <<Uuid>> = binary_to_list(Key),
    [?MODULE:get({notice, Uuid}) | ?MODULE:get_notices_by_keys(Keys)];
get_notices_by_keys([]) ->
    [].
