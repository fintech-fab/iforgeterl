%%%-------------------------------------------------------------------
%%% @author b00ris
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jun 2014 9:18
%%%-------------------------------------------------------------------
-module(groups).
-author("b00ris").

%% API
-compile(export_all).


create({group, Name,Author})->
    Command = "HMSET",
    Uuid=1,
    Key = "group:"++Uuid,
    Attributes = [Name,Author],
    Value =  redis:call({send_redis,{Command,Key,Attributes}}),
    Value.

add({group, Name,Author},Uuid)->
    Command = "SADD",
    Uuid=1,
    Key = "group:"++Uuid,
    Attributes = [Name,Author],
    Value =  redis:call({send_redis,{Command,Key,Attributes}}),
    Value.
