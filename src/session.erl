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
-compile({no_auto_import, [get/1]}).

%% API
-export([]).


start({user, User}) ->
    UserUuid = uuid:to_string(uuid:uuid4()),
    Key = "session:" ++ UserUuid,
    Attributes = ["user", User],
    redis:hmset(Key, Attributes),
    UserUuid.


get({session, Uuid}) ->
    Key = "session:" ++ Uuid,
    {ok, Value} = redis:hgetall(Key),
    Value.
