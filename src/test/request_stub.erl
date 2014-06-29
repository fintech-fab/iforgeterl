%%%-------------------------------------------------------------------
%%% @author topas
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. июн 2014 13:43
%%%-------------------------------------------------------------------
-module(request_stub).
-author("topas").

%% API
-export([respond/1, parse_post/0]).

respond(Result) ->
    Result.

parse_post() ->
    [{"datetime", 1401010}, {"group", "test@example.com"}, {"notice", "Example"}].

