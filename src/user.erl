%%%-------------------------------------------------------------------
%%% @author b00ris
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Jun 2014 12:24
%%%-------------------------------------------------------------------
-module(user).
-author("b00ris").

%% API
-compile(export_all).


add(RedisConnection, {user, Username, Email, Phone}) ->
    UserUuid = uuid:to_string(uuid:uuid4()),
    {ok, <<"OK">>} = eredis:q(RedisConnection, ["HMSET", "user:" ++ UserUuid, "username", Username, "email", Email, "phone", Phone]),
    UserUuid.


get(RedisConnection, {user, Uuid}) ->
    {ok, Value} = eredis:q(RedisConnection, ["HGETALL", "user:" ++ Uuid]),
    Value.

