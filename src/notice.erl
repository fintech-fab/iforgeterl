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
    NoticeUuid = uuid:to_string(uuid:uuid4()),
    Key = ?PREFIX ++ NoticeUuid,

    Author = "default",
    Attributes = ["group", "group:"++Group, "message", Text, "datetime", Datetime, "author", Author],
    redis:hmset(Key,Attributes),
    NoticesUuid = notices:add({notices, Key, Datetime}),
    [list_to_binary(NoticeUuid), list_to_binary(NoticesUuid)].

get({notice_uuid, Uuid}) ->
    Key = key({notice_uuid, Uuid}),
    {ok, Notice} = redis:hgetall(Key),
    Notice.

get_all() ->
    Key = "KEYS", ?PREFIX ++ "*",
    {ok, Keys} = redis:keys(Key),
    get_notices_by_keys(Keys).

key({notice_uuid, Uuid}) ->
    ?PREFIX ++ Uuid.

remove({notice_uuid, Uuid}) ->
    Key=?PREFIX ++ Uuid,
    {ok, <<"1">>} = redis:del(Key),
    ok.

get_notices_by_keys([Key | Keys]) ->
        ?PREFIX ++ <<Uuid>> = binary_to_list(Key),
    [?MODULE:get({notice, Uuid}) | ?MODULE:get_notices_by_keys(Keys)];
get_notices_by_keys([]) ->
    [].
