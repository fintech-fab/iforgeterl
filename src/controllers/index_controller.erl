%%%-------------------------------------------------------------------
%%% @author petrov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. июл 2014 16:29
%%%-------------------------------------------------------------------
-module(index_controller).
-author("petrov").

%% API
-export([index/1]).

index(Req) ->
    QueryStringData = Req:parse_qs(),
    Username = proplists:get_value("datetime", QueryStringData, iso_fmt:iso_8601_fmt(erlang:localtime())),
    render:render_ok(Req, send_form_dtl, [{datetime, Username}], [{header, notice_dtl}]).
