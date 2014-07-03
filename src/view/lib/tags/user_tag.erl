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
-export([user_name/1, mask_phone/1, mask_email/1, version/0, inventory/1]).

%% --------------------------------------------------------------------
%% Definitions
%% --------------------------------------------------------------------


version() -> 1.
inventory(tags) -> [];
inventory(filters) -> [user_name, mask_email, mask_phone].

user_name(UserKey) ->
    User = user:get(UserKey),
    Username = proplists:get_value(username, User),
    Username.

mask_phone(_Phone) ->
    "".

mask_email(Email) ->
    case re:run(Email, "^[\\w_]+@") of
        {match, _} ->
            MaskEmail = re:replace(Email, "^(\\w{0,2})([\\w_\\d]+)([\\w\\d_]{1})@", "\\1***\\3@", [{return,list}]),
            MaskEmail;
        nomatch ->
            Email
    end.



