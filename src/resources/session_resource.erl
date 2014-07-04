%%%-------------------------------------------------------------------
%%% @author petrov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. июл 2014 16:19
%%%-------------------------------------------------------------------
-module(session_resource).
-author("petrov").

%% API
-export([post/2]).


post(Req, {url_params, _Params}) ->

    Username = erlang:get(user),

    case Username of
        undefined ->
            header:json({ok, Req}, []);
        _ ->
            header:json({ok, Req}, {struct, [{uuid, list_to_binary(Username)}]})
    end.



