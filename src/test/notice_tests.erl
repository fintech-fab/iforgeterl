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
    BinaryUuid = proplists:get_value(<<"notice_uuid">>, Result),
    NoticeUuid = binary_to_list(BinaryUuid),

    Notice = notice:get({notice_uuid, NoticeUuid}),
    Author = proplists:get_value(author, Notice),
    Datetime = proplists:get_value(datetime, Notice),
    Message = proplists:get_value(message, Notice),
    GroupUuid = proplists:get_value(group, Notice),

    Group = groups:get(binary_to_list(GroupUuid)),

    GroupInfo = proplists:get_value(info, Group),
    GroupName = proplists:get_value(name, GroupInfo),
    GroupAuthor = proplists:get_value(author, GroupInfo),

    GroupMembers = proplists:get_value(members, Group),

    [
        ?_assert(HttpStatus =:= 200),
        ?_assert(HttpHeaders =:= [{"Content-Type", "application/json"}]),
        ?_assert(Struct =:= struct),
        ?_assert(NoticeUuid =/= []),
        ?_assert(Author =:= <<"default">>),
        ?_assert(Datetime =:= <<"1401010">>),
        ?_assert(Message =:= <<"Example">>),
        ?_assert(GroupUuid =/= <<"">>),
        ?_assert(GroupUuid =/= []),
        ?_assert(GroupName =:= <<"default">>),
        ?_assert(GroupAuthor =:= <<"312321">>),
        ?_assert(GroupMembers =:= [<<"user:test@example.com">>])
    ].


