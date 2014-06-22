%%%-------------------------------------------------------------------
%%% @author topas
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. июн 2014 15:47
%%%-------------------------------------------------------------------
-module(cookie).
-author("topas").

%% API
%% -compile({no_auto_import,[get/3, set/1]}).
-export([get/3, set/2]).

get(Req, Key, Default) ->
    case Req:get_cookie_value(Key) of
        undefined -> Default;
        Value -> Value
    end.

set(Key, Value) ->
    Cookie = mochiweb_cookies:cookie(Key, Value, [{path, "/"}]),
    OriginCookies = erlang:get(cookies),

    NewCookies = [],
    case OriginCookies of
        undefined ->
            void;
        _ ->
            lists:append(NewCookies, OriginCookies)
    end,

    lists:append(NewCookies, [Cookie]),
    erlang:put(cookies, NewCookies),

    Cookie.
