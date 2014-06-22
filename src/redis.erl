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
-export([start/0, call/1, exist_key/1]).
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

exist_key(Name) ->
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


%%
%% add(RedisConnection, {user, Username, Email, Phone}) ->
%%     UserUuid = uuid:to_string(uuid:uuid4()),
%%     {ok, <<"OK">>} = eredis:q(RedisConnection, ["HMSET", "user:" ++ UserUuid, "username", Username, "email", Email, "phone", Phone]),
%%     UserUuid.
%%
%%
%% get(RedisConnection, {user, Uuid}) ->
%%     {ok, Value} = eredis:q(RedisConnection, ["HGETALL", "user:" ++ Uuid]),
%%     Value.