%%%-------------------------------------------------------------------
%%% @author petrov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. июл 2014 15:39
%%%-------------------------------------------------------------------
-module(notice_resource).
-author("petrov").
-compile(export_all).
%% API
-export([]).



get(Req, {url_params, _Params}) ->
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode(notice:get_all())
    }).

get(Req, {url_params, _Params}, {id, Id}) ->
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode(notice:get({notice_uuid, Id}))
    }).

post(Req, {url_params, _Params}) ->
    QueryStringData = Req:parse_post(),

    Text = proplists:get_value("notice", QueryStringData),
    Datetime = proplists:get_value("datetime", QueryStringData),
    Group = proplists:get_value("group", QueryStringData),

    Author = auth:get(),
    Emails = string:tokens(Group, ","),

    case notice_service:add(Text, Datetime, Author, {raw, Emails}) of

        {ok, Notice} ->
            BinaryNoticeUuid = list_to_binary(Notice),
            header:json({ok, Req}, {struct, [{uuid, BinaryNoticeUuid}]});

        {error, Message} ->
            BinaryMessage = list_to_binary(Message),
            header:json({ok, Req}, {struct, [{error, BinaryMessage}]})

    end.

delete(Req, {url_params, _Params}, {id, Id}) ->
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode(notice:remove({notice_uuid, Id}))

    }).

