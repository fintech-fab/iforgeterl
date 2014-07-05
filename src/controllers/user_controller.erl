%%%-------------------------------------------------------------------
%%% @author petrov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. июл 2014 16:34
%%%-------------------------------------------------------------------
-module(user_controller).
-author("petrov").
-compile(export_all).
%% API
-export([]).

-import(render, [render_ok/2, render_ok/3]).

index(Req) ->
    render_ok(Req, auth_dtl).

auth(Req) ->
    render_ok(Req, auth_dtl).

auth(post, Req) ->
    PostData = Req:parse_post(),
    Username = proplists:get_value("email", PostData),
    Password = proplists:get_value("password", PostData),

    %% TODO
    %% Пустые имя пользователя или пароль

    case user:auth(Username, Password) of
        true ->
            auth:login(Username),
            header:redirect(Req, "/");
        false ->
            render_ok(Req, auth_dtl)
    end.

signup(Req) ->
    render_ok(Req, signup_dtl).

logout(Req) ->
    erlang:put(user, []),
    cookie:del("sess"),

    %% TODO
    %% Очистить сессию в redis

    header:redirect(Req, "/").
