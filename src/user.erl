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


add({user, Username, Email, Phone}) ->
    redis:start(),
    Command="HMSET",
    UserUuid = uuid:to_string(uuid:uuid4()),
    Key="user:" ++ UserUuid,
    Attributes = ["username", Username, "email", Email, "phone", Phone],
    redis:call({send_redis,{Command,Key,Attributes}}),
    UserUuid.

%%
%%     UserUuid = uuid:to_string(uuid:uuid4()),
%%     {ok, <<"OK">>} = eredis:q(RedisConnection, ["HMSET", "user:" ++ UserUuid, "username", Username, "email", Email, "phone", Phone]),



get({user, Uuid}) ->
    redis:start(),
    Command="HGETALL",
    Key="user:" ++ Uuid,
    {ok, Value} = redis:call({send_redis,{Command,Key}}),
    io:write(Value),
    Value.





