%%%-------------------------------------------------------------------
%%% @author mart
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. июн 2014 16:38
%%%-------------------------------------------------------------------
-module(iforget).
-author("mart").

-export([start/0, stop/0]).

ensure_started(App) ->
  case application:start(App) of
    ok ->
      ok;
    {error, {already_started, App}} ->
      ok
  end.


%% @spec start() -> ok
%% @doc Start the mochiwebapp server.
start() ->
  ensure_started(crypto),
  ensure_started(eredis),
  ensure_started(iforget).


%% @spec stop() -> ok
%% @doc Stop the mochiwebapp server.
stop() ->
  application:stop(iforget),
  application:stop(eredis),
  application:stop(crypto).
