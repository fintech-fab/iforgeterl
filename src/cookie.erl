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
-export([get/3, set/2, del/1]).

get(Req, Key, Default) ->
    case Req:get_cookie_value(Key) of
        undefined -> Default;
        Value -> Value
    end.

set(Key, Value) ->
    Cookie = mochiweb_cookies:cookie(Key, Value, [{path, "/"}]),
    append(Cookie),
    Cookie.

del(Key) ->
    Cookie = mochiweb_cookies:cookie(Key, "deleted", [{path, "/"}, {max_age, 0}]),
    append(Cookie),
    Cookie.

append(Cookie) ->
    OriginCookies = erlang:get(cookies),

    NewCookies = [],
    case OriginCookies of
        undefined ->
            void;
        _ ->
            lists:append(NewCookies, OriginCookies)
    end,

    ResultCookies = [Cookie | NewCookies],
    erlang:put(cookies, ResultCookies).
