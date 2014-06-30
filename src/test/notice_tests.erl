%%%-------------------------------------------------------------------
%%% @author topas
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. июн 2014 13:37
%%%-------------------------------------------------------------------
-module(notice_tests).
-author("topas").

-include_lib("eunit/include/eunit.hrl").

%% API
-export([]).

post_test_() ->

    {
        HttpStatus,
        HttpHeaders,
        JsonResult
    } = rest_handler:handle({post, "notice", request_stub}),

    {Struct, Result} = mochijson2:decode(JsonResult),
    BinaryUuid = proplists:get_value(<<"uuid">>, Result),
    NoticeUuid = binary_to_list(BinaryUuid),

    Notice = notice:get({notice_uuid, NoticeUuid}),
    Author = proplists:get_value(author, Notice),
    Datetime = proplists:get_value(datetime, Notice),
    Message = proplists:get_value(message, Notice),

    BinaryGroupUuid = proplists:get_value(group, Notice),

    %% group:97651470-d365-41cb-9243-f1bac1bcfeea
    GroupUuid = binary_to_list(BinaryGroupUuid),

    Group = groups:get(GroupUuid),

    GroupName = proplists:get_value(name, Group),
    GroupAuthor = proplists:get_value(author, Group),

    GroupMembers = groups:member(GroupUuid),

    [
        ?_assert(HttpStatus =:= 200),

%%         ?_assert(HttpHeaders =:= [{"Content-Type", "application/json"}]),
        ?_assert(Struct =:= struct),
        ?_assert(NoticeUuid =/= []),
        ?_assert(Author =:= <<"user:test@example.com">>),
        ?_assert(Datetime =:= <<"1401010">>),
        ?_assert(Message =:= <<"Example">>),
        ?_assert(GroupUuid =/= <<"">>),
        ?_assert(GroupUuid =/= []),
        ?_assert(Group =:= [{author,<<"user:test@example.com">>},{name,<<"self">>}]),
        ?_assert(GroupName =:= <<"self">>),
        ?_assert(GroupAuthor =:= <<"user:test@example.com">>),
        ?_assert(is_list(Group) =:= true),
        ?_assert(GroupMembers =:= [<<"user:test@example.com">>])
    ].


