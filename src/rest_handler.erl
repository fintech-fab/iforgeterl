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
    {ok, RedisConnection} = eredis:start_link(),
    {ok, Keys} = eredis:q(RedisConnection, ["KEYS" | ["notice:*"]]),

    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode(notice:get_notices(Keys, RedisConnection))
    });

handle({get, "notice/" ++ NoticeUuid, Req}) ->
    {ok, RedisConnection} = eredis:start_link(),
    {ok, Value} = eredis:q(RedisConnection, ["GET", "notice:" ++ NoticeUuid]),

    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"notice">>, Value}, {<<"uuid">>, list_to_binary(NoticeUuid)}])
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
    QueryStringData = Req:parse_qs(),
    Text = proplists:get_value("text", QueryStringData, "tets"),
    {ok, RedisConnection} = eredis:start_link(),
    NoticeUuid = uuid:to_string(uuid:uuid4()),
    {ok, <<"OK">>} = eredis:q(RedisConnection, ["SET", "notice:" ++ NoticeUuid, Text]),

    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"ok">>, <<"ok">>}, {<<"uuid">>, list_to_binary(NoticeUuid)}])
    });

handle({_, _, Req}) ->
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"error">>, <<"unknown method">>}])
    }).

