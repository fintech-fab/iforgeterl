%%%-------------------------------------------------------------------
%%% @author topas
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. июл 2014 18:53
%%%-------------------------------------------------------------------
-module(user_tag).
-author("topas").
-behaviour(erlydtl_library).

%% API
-export([user_name/1, version/0, inventory/1]).

%% --------------------------------------------------------------------
%% Definitions
%% --------------------------------------------------------------------


version() -> 1.
inventory(tags) -> [];
inventory(filters) -> [user_name].

user_name(UserKey) ->
    User = user:get(UserKey),
    Username = proplists:get_value(username, User),
    Username.


