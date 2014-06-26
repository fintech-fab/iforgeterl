%%%-------------------------------------------------------------------
%%% @author mart
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. июн 2014 9:37
%%%-------------------------------------------------------------------
-module(header).
-author("mart").

%% API
-export([send/1, redirect/2, json/2]).

send({ok, Req}) ->

    Req:respond({200, getHeaders(),
        "Hello get !\n"});
send({error, Req}) ->
    Req:respond({500, getHeaders(),
        "Internal service error !\n"});
send({not_find, Req}) ->
    Req:respond({200, [{"Content-Type", "text/plain"}],
        "Hello get !\n"}).

json({ok, Req}, Data) ->
    Headers = getHeaders("application/json"),
    Req:respond({200, Headers, mochijson2:encode([{<<"uuid">>, list_to_binary(Data)}])}).

redirect(Req, Url) ->
    Headers = getHeaders(),
    Req:respond({301, lists:append(Headers, [{"Location", Url}]), ""}).

getHeaders() ->
    Headers = getHeaders("text/plain").

getHeaders(ContentType) ->

    Headers = [
        {"Content-Type", ContentType},
        {"Cache-Control", "no-store, no-cache, must-revalidate"},
        {"Expires", "Sat, 26 Jul 1997 05:00:00 GMT"}
    ],

    Cookies = erlang:get(cookies),
    case Cookies of
        undefined ->
            Headers;
        _ ->
            lists:append(Headers, Cookies)
    end.
