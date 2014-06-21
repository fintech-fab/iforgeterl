%%%-------------------------------------------------------------------
%%% @author topas
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. июн 2014 15:32
%%%-------------------------------------------------------------------
-module(session).
-author("topas").

%% API
-compile(export_all).

%% API
-export([]).

add(RedisConnection, {user, Username, Email, Phone}) ->
    UserUuid = uuid:to_string(uuid:uuid4()),
    {ok, <<"OK">>} = eredis:q(RedisConnection, ["HMSET" | ["user:" ++ UserUuid, "username", Username, "email", Email, "phone", Phone]]),
    UserUuid.


get(RedisConnection, {user, Uuid}) ->
    {ok, Value} = eredis:q(RedisConnection, ["HGETALL", "user:" ++ Uuid]),
    Value.
