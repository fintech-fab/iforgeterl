%%%-------------------------------------------------------------------
%%% @author topas
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. июн 2014 0:15
%%%-------------------------------------------------------------------
-module(notice_controller).
-author("topas").

%% API
-export([add/4]).

add([], _, _, _) ->
    {error, "Message required"};

add(Text, Datetime, Author, Emails) ->
    Group = group_controller:add(Author, Emails),
    add(Text, Datetime, Group).

add(_, _, {error, Message}) ->
    {error, Message};

add(Text, Datetime, {ok, GroupUid}) ->
    Notice = notice:add({notice, GroupUid, Datetime, Text}),
    {ok, Notice}.
