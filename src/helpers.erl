%%%-------------------------------------------------------------------
%%% @author topas
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. июн 2014 23:32
%%%-------------------------------------------------------------------
-module(helpers).
-author("topas").

%% API
-export([md5/1]).

md5(String) ->
    B = erlang:md5(String),
    H = lists:flatten([io_lib:format("~2.16.0b", [C]) || <<C>> <= B]),
    H.

