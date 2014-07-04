%%%-------------------------------------------------------------------
%%% @author petrov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. июл 2014 14:54
%%%-------------------------------------------------------------------
-module(group_resource).
-author("petrov").

-compile(export_all).
%% API
-export([]).



get(Req,{url_params,_Params},{id,Id})->
  Group = groups:get({uuid, Id}),
  Req:respond({
    200,
    [{"Content-Type", "application/json"}],
    mochijson2:encode(Group)
  }).


post(Req,{url_params,_Params})->
  PostData = Req:parse_post(),

  Name = proplists:get_value("name", PostData),
  Username = erlang:get(user),
  Author = "user:" ++ Username,
  Uuid = groups:create({group, Name, Author}),

  Req:respond({
    200,
    [{"Content-Type", "application/json"}],
    mochijson2:encode([{<<"group">>, list_to_binary(Uuid)}])
  }).

