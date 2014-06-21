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

-import(render, [render_ok/2]).

handle({get, "", Req}) ->
    %% TODO Cоздание коннекта к базе вынести
    {ok, RedisConnection} = eredis:start_link(),
    render_ok(Req, auth_dtl);

handle({post, "auth", Req}) ->

    PostData = Req:parse_post(),
    Username = proplists:get_value("login", PostData),
    Password = proplists:get_value("password", PostData),

    case user:auth(Username, Password) of
        true ->
            Req:ok({"text/html", "OK"});
        false ->
            Req:ok({"text/html", "false"})
    end;

handle({_, _, Req}) ->
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"error">>, <<"unknown method">>}])
    }).


%%     Session = Req:get_cookie("sess"),
%%     Req:ok("ssss");
