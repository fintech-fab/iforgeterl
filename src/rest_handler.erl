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

handle({get, "message/", Req}) ->
    {ok, RedisConnection} = eredis:start_link(),
    QueryStringData = Req:parse_qs(),
    MessageUuid = proplists:get_value("uuid", QueryStringData),

    {ok, Value} = eredis:q(RedisConnection, ["GET", "message:" ++ MessageUuid]),

    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"message">>, Value}, {<<"uuid">>, list_to_binary(MessageUuid)}])
    });

handle({get, "message/list", Req}) ->
    {ok, RedisConnection} = eredis:start_link(),
    {ok, Keys} = eredis:q(RedisConnection, ["KEYS" | ["message:*"]]),

    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode(getMessages(RedisConnection, Keys))
    });

handle({get, "user/" ++ Uuid, Req}) ->
    User = user:get({user, Uuid}),
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"ok">>, <<"ok">>}, {<<"user">>, User}])
    });

handle({post, "user", Req}) ->
    PostData = Req:parse_post(),

    Username = proplists:get_value("username", PostData),
    Email = proplists:get_value("email", PostData),
    Phone = proplists:get_value("phone", PostData),

    Uuid = user:add({
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


handle({post, _ApiMethod, Req}) ->
    QueryStringData = Req:parse_qs(),
    Text = proplists:get_value("text", QueryStringData, "tets"),
    {ok, RedisConnection} = eredis:start_link(),
    MessageUuid = uuid:to_string(uuid:uuid4()),
    {ok, <<"OK">>} = eredis:q(RedisConnection, ["SET", "message:" ++ MessageUuid, Text]),

    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"ok">>, <<"ok">>}, {<<"uuid">>, MessageUuid}])
    });

handle({get, _ApiMethod, Req}) ->
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"error">>, <<"unknown method">>}])
    })
.

getMessages(_, []) ->
    [];
getMessages(RedisConnection, [H | T]) ->
    {ok, Message} = eredis:q(RedisConnection, ["GET", H]),
        "message:" ++ Uuid = H,
    [{Uuid, Message} | getMessages(RedisConnection, T)].

