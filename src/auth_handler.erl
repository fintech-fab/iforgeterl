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

handle({post, "auth", Req}) ->

    PostData = Req:parse_post(),
    Username = proplists:get_value("login", PostData),
    Password = proplists:get_value("password", PostData),

    case user:auth(Username, Password) of
        true ->
            Session = session:start({user, Username}),
            Cookie = cookie:set("sess", Session),

            Req:respond({301, [Cookie, {"Location", "/"}], ""});
        false ->
            render_ok(Req, auth_dtl, [{username, Username}])
    end;

handle({_, _, Req}) ->
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"error">>, <<"unknown method">>}])
    }).


%%     Session = Req:get_cookie("sess"),
%%     Req:ok("ssss");
