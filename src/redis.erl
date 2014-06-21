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
-define(SERVER, redis).
%% API
-export([start/0, call/1]).
-export([loop/1]).

start()->
    {ok, RedisConnection} = eredis:start_link(),
    Pid = spawn(redis, loop, [RedisConnection]),
    erlang:register(?SERVER, Pid).

call({send_redis,{Command,Key}})->
    ?SERVER ! {send_redis, {Command,Key}};

call({send_redis,{Command,Key, Attributes}})->
    ?SERVER ! {send_redis, {Command,Key,Attributes}}.


loop(RedisConnection)->
    receive
        {send_redis,{Command,Key}} ->
            eredis:q(RedisConnection, [Command, Key]),
            loop(RedisConnection);
        {send_redis,{Command,Key,Attributes}} ->
            eredis:q(RedisConnection, [Command, Key | Attributes]),
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