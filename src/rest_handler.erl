%%%-------------------------------------------------------------------
%%% @author mart
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. июн 2014 17:43
%%%-------------------------------------------------------------------
-module(rest_handler).
-author("mart").

%% API
-export([handle/1]).

handle({get, "notice/", Req}) ->

    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode(notice:get_all())
    });

handle({get, "notice/" ++ NoticeUuid, Req}) ->
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode(notice:get({notice_uuid,NoticeUuid}))
    });

handle({get, "user/" ++ Uuid, Req}) ->
    {ok, RedisConnection} = eredis:start_link(),
    User = user:get(RedisConnection, {user, Uuid}),
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"ok">>, <<"ok">>}, {<<"user">>, User}])
    });

handle({post, "user", Req}) ->
    PostData = Req:parse_post(),
    {ok, RedisConnection} = eredis:start_link(),

    Username = proplists:get_value("username", PostData),
    Email = proplists:get_value("email", PostData),
    Phone = proplists:get_value("phone", PostData),

    Uuid = user:add(RedisConnection, {
        user,
        Username,
        Email,
        Phone
    }),
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"uuid">>, list_to_binary(Uuid)}])
    });

handle({post, "notice/", Req}) ->
    QueryStringData = Req:parse_post(),
    %% [{"datetime",Datetime},{"group",Group,{"notice",Text}] = QueryStringData,

    Text = proplists:get_value("notice",QueryStringData),
    Datetime = proplists:get_value("datetime",QueryStringData),
    Group = proplists:get_value("group",QueryStringData),

    NoticeUuid = notice:add({notice, Group, Datetime, Text}),

    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{ok,ok}, {notice_uuid, NoticeUuid}])
    });

handle({_, _, Req}) ->
    Req:respond({
        404,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"error">>, <<"unknown method">>}])
    }).

