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

add({notices, NoticeName}) ->
    NoticesUuid = uuid:to_string(uuid:uuid4()),

    {Mega, Secs, _} = now(),
    Timestamp = Mega * 1000000 + Secs,

    redis:zadd("notices", [Timestamp, NoticeName]),
    NoticesUuid;

add({notices, NoticeName, Datetime}) ->
    NoticesUuid = uuid:to_string(uuid:uuid4()),

    redis:zadd("notices", [Datetime, NoticeName]),
    NoticesUuid.
