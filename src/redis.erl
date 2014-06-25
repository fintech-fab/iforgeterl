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
-export([exist/1, hset/2,hmset/2, hgetall/2,set/2,zadd/2,smembers/2,sadd/2]).
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
    Value.


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

hset(Key,Attributes)->
    Command = "HSET",
    redis:call({send_redis, {Command, Key, Attributes}}).

hmset(Key,Attributes)->
    Command = "HMSET",
    redis:call({send_redis, {Command, Key, Attributes}}).

hgetall(Key,Attributes)->
    Command = "HGETALL",
    redis:call({send_redis, {Command, Key, Attributes}}).


set(Key,Attributes)->
    Command = "HMSET",
    redis:call({send_redis, {Command, Key, Attributes}}).

zadd(Key,Attributes)->
    Command = "ZADD",
    redis:call({send_redis, {Command, Key, Attributes}}).

sadd(Key,Attributes)->
    Command = "SADD",
    redis:call({send_redis, {Command, Key, Attributes}}).

smembers(Key,Attributes)->
    Command = "SMEMBERS",
    redis:call({send_redis, {Command, Key, Attributes}}).

%% parse_fields([K,V|L],Acc)->
%%     parse_fields([K,V|L],[{K,V}|Acc])
%%     Acc.
%% parse_fields(L)->


get_tuple(Attribute, Value)->
    {list_to_atom(Attribute),Value}.
