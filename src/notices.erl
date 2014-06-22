%%%-------------------------------------------------------------------
%%% @author mart
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. июн 2014 15:04
%%%-------------------------------------------------------------------
-module(notices).
-author("mart").

%% APIa
-export([add/1]).
-define(PREFIX, "notices:").

add({notices,NoticeName}) ->
    NoticesUuid = uuid:to_string(uuid:uuid4()),
    Key = ?PREFIX ++ NoticesUuid,
    redis:call({send_redis,{"ZADD",Key,[os:timestamp(),NoticeName]}}),
    NoticesUuid.
