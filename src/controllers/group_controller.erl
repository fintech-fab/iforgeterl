%%%-------------------------------------------------------------------
%%% @author petrov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. июл 2014 16:29
%%%-------------------------------------------------------------------
-module(group_controller).
-author("petrov").

%% API
-export([index/1]).

-import(render, [render_ok/2, render_ok/3]).

index(Req) ->

    Path = Req:get(path),
    index(Req, Path).

index(Req, "/group/" ++ GroupUuid) ->

    Group = groups:get({uuid, GroupUuid}),

    case Group of
        [] ->
            render_ok(Req, not_found_dtl);
        _ ->
            Members = groups:member({uuid, GroupUuid}),
            render_ok(Req, group_dtl, [{group, Group}, {members, Members}])
    end.
