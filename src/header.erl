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
-export([send/1, redirect/2]).

send({ok, Req}) ->

    Req:respond({200, getHeaders(),
        "Hello get !\n"});
send({error, Req}) ->
    Req:respond({500, getHeaders(),
        "Internal service error !\n"});
send({not_find, Req}) ->
    Req:respond({200, [{"Content-Type", "text/plain"}],
        "Hello get !\n"}).

redirect(Req, Url) ->
    Headers = getHeaders(),
    lists:append(Headers, [{"Location", Url}]),
    Req:respond({301, Headers, ""}).

getHeaders() ->
    Headers = [{"Content-Type", "text/plain"}],

    Cookies = erlang:get(cookies),
    case Cookies of
        undefined ->
            void;
        _ ->
            lists:append(Headers, Cookies)
    end,

    Headers.

