%%%-------------------------------------------------------------------
%%% @author mart
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. июн 2014 17:43
%%%-------------------------------------------------------------------
-module(rest_handler).
-author("mart").

%% API
-export([handle/1]).

handle({get,ApiMethod,Req}) ->
  Req:respond({
      200,
      [{"Content-Type", "application/json"}],
      mochijson2:encode([{<<"test">>,list_to_binary(ApiMethod)},{<<"test">>,list_to_binary(ApiMethod)}])
  });
handle({post,ApiMethod,Req}) ->
  Req:respond({
    200,
    [{"Content-Type", "application/json"}],
    mochijson2:encode([{<<"test">>,list_to_binary(ApiMethod)},{<<"test">>,list_to_binary(ApiMethod)}])
  }).

parse_method(ApiMethodString) ->
  string:
  ok.