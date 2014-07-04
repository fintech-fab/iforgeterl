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
  render_ok(Req, auth).

signup(Req) ->
  render_ok(Req, signup).

logout(Req) ->
  erlang:put(user, []),
  cookie:del("sess"),

  %% TODO
  %% Очистить сессию в redis

  header:redirect(Req, "/").