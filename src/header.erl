%%%-------------------------------------------------------------------
%%% @author mart
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. июн 2014 9:37
%%%-------------------------------------------------------------------
-module(header).
-author("mart").

%% API
-export([send/1]).

send({ok,Req}) ->
  Req:respond({200, [{"Content-Type", "text/plain"}],
    "Hello get !\n"});
send({error,Req}) ->
  Req:respond({500, [{"Content-Type", "text/plain"}],
    "Internal service error !\n"});
send({not_find,Req}) ->
  Req:respond({200, [{"Content-Type", "text/plain"}],
    "Hello get !\n"}).
