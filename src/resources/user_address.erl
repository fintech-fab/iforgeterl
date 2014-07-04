%%%-------------------------------------------------------------------
%%% @author petrov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. июл 2014 15:49
%%%-------------------------------------------------------------------
-module(user_address).
-author("petrov").
-compile(export_all).
%% API
-export([]).



get(Req,{url_params,Params})->
  Uuid =proplists:get_value(user,Params),
  User = user:get_address(Uuid),
  Req:respond({
    200,
    [{"Content-Type", "application/json"}],
    mochijson2:encode([{<<"ok">>, <<"ok">>}, {<<"user">>, list_to_binary(User)}])
  }).


post(Req,{url_params,Params})->
  Uuid =proplists:get_value(user,Params),
  PostData = Req:parse_post(),
  Email = proplists:get_value("email", PostData),
  Phone = proplists:get_value("phone", PostData),

  User = user:set_address({address, Email, Phone}, Uuid),

  Req:respond({
    200,
    [{"Content-Type", "application/json"}],
    mochijson2:encode([{<<"ok">>, <<"ok">>}, {<<"user">>, list_to_binary(User)}])
  }).
