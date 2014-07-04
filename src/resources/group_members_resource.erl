%%%-------------------------------------------------------------------
%%% @author petrov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. июл 2014 10:27
%%%-------------------------------------------------------------------
-module(group_members_resource).
-author("petrov").
-compile(export_all).
%% API
-export([]).



get(Req, {url_params, Params}) ->
    header:json({ok, Req}, [Params]).

get(Req, {url_params, Params}, {id, Id}) ->
    header:json({ok, Req}, [Params, Id]).

post(Req, {url_params, Params}) ->
    Uuid = proplists:get_value(group, Params),
    PostData = Req:parse_post(),
    Username = proplists:get_value("username", PostData),
    groups:add({group, Username}, Uuid),
    Group = groups:get({uuid, Uuid}),
    header:json({ok, Req}, <<"ok">>).


%% header:json({ok,Req},[[list_to_atom(Username),list_to_atom(Uuid),Params,PostData]]).,
%%   header:json({ok,Req},[Params]).

put(Req, {url_params, Params}, {id, Id}) ->
    header:json({ok, Req}, [Params, Id]).

delete(Req, {url_params, Params}, {id, Id}) ->
    header:json({ok, Req}, [Params, Id]).

