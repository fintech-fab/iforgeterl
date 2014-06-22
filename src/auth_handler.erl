%%%-------------------------------------------------------------------
%%% @author topas
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. июн 2014 15:43
%%%-------------------------------------------------------------------
-module(auth_handler).
-author("topas").

%% API
-export([handle/1]).

-import(render, [render_ok/2, render_ok/3]).

handle({get, "", Req}) ->
    render_ok(Req, auth_dtl);

handle({get, "signup", Req}) ->
    render_ok(Req, signup_dtl);

handle({post, "auth", Req}) ->

    PostData = Req:parse_post(),
    Username = proplists:get_value("login", PostData),
    Password = proplists:get_value("password", PostData),

    case user:auth(Username, Password) of
        true ->
            auth:login(Username),
            header:redirect(Req, "/");
        false ->
            render_ok(Req, auth_dtl, [{username, Username}])
    end;

handle({_, _, Req}) ->
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"error">>, <<"unknown method">>}])
    }).


