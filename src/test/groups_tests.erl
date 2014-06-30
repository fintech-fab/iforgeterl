%%%-------------------------------------------------------------------
%%% @author topas
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. июн 2014 14:20
%%%-------------------------------------------------------------------
-module(groups_tests).
-author("topas").

-include_lib("eunit/include/eunit.hrl").

%% API
-export([]).

group_test_() ->
    Uuid = groups:create({group, "GroupName", "TestUser"}),

    Group = groups:get("group:" ++ Uuid),
    Author = proplists:get_value(author, Group),
    GroupName = proplists:get_value(name, Group),

    GroupGetByUuid = groups:get({uuid, Uuid}),

    [
        ?_assert(Uuid =/= []),
        ?_assert(Author =:= <<"TestUser">>),
        ?_assert(GroupName =:= <<"GroupName">>),
        ?_assert(Group =:= GroupGetByUuid)
    ].
