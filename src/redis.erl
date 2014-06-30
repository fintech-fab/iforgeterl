%%%-------------------------------------------------------------------
%%% @author b00ris
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Jun 2014 14:47
%%%-------------------------------------------------------------------
-module(redis).
-author("b00ris").
-define(SERVER, iredis).
%% API
-export([start/0, call/1]).
-export([exist/1, hset/2, hmset/2, hgetall/1, get/1, set/2, zadd/2, smembers/1, sadd/2, del/1, keys/1]).
-export([loop/1]).

start() ->
    {ok, RedisConnection} = eredis:start_link(),
    Pid = spawn_link(redis, loop, [RedisConnection]),
    erlang:register(?SERVER, Pid).

call({send_redis, {Command, Key}}) ->
    ?SERVER ! {send_redis, {self, self()}, {Command, Key}},
    receive
        Response ->
            Response
    end;

call({send_redis, {Command, Key, Attributes}}) ->
    ?SERVER ! {send_redis, {self, self()}, {Command, Key, Attributes}},
    receive
        Response ->
            Response
    end.

exist(Name) ->
    Command = "EXISTS",
    Key = Name,
    {ok, Value} = redis:call({send_redis, {Command, Key}}),

    case Value of
        <<"0">> ->
            false;
        <<"1">> ->
            true
    end.


loop(RedisConnection) ->
    receive
        {send_redis, {self, Pid}, {Command, Key}} ->
            Value = eredis:q(RedisConnection, [Command, Key]),
            Pid ! Value,
            loop(RedisConnection);
        {send_redis, {self, Pid}, {Command, Key, Attributes}} ->
            Value = eredis:q(RedisConnection, [Command, Key | Attributes]),
            Pid ! Value,
            loop(RedisConnection);
        Oops ->
            io:write(Oops)
    end.

hset(Key, Attributes) ->
    redis:call({send_redis, {"HSET", Key, Attributes}}).

hmset(Key, Attributes) ->
    redis:call({send_redis, {"HMSET", Key, Attributes}}).

hgetall(Key) ->
    {ok, Result} = redis:call({send_redis, {"HGETALL", Key}}),
    {ok, list_to_tagged_list(Result)}.


set(Key, Attributes) ->
    redis:call({send_redis, {"SET", Key, Attributes}}).

get(Key) ->
    redis:call({send_redis, {"GET", Key}}).

zadd(Key, Attributes) ->
    redis:call({send_redis, {"ZADD", Key, Attributes}}).

sadd(Key, Attributes) ->
    redis:call({send_redis, {"SADD", Key, Attributes}}).

smembers(Key) ->
    redis:call({send_redis, {"SMEMBERS", Key}}).

keys(Key) ->
    redis:call({send_redis, {"KEYS", Key}}).

del(Key) ->
    redis:call({send_redis, {"DEL", Key}}).


%% Обработка
list_to_tagged_list(L) ->
    list_to_tagged_list(L, []).

list_to_tagged_list([], Acc) ->
    Acc;

list_to_tagged_list([K, V | L], Acc) ->
    list_to_tagged_list(L, [get_tuple(K, V)] ++ Acc).

get_tuple(Attribute, Value) ->
    {binary_to_atom(Attribute, utf8), Value}.
