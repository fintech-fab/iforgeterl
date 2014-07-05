%%%-------------------------------------------------------------------
%%% @author petrov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. июл 2014 16:25
%%%-------------------------------------------------------------------
-module(auth_resource).
-author("petrov").

%% API
-export([post/2]).
-import(render, [render_ok/2]).


post(Req, {url_params, _Params}) ->
    PostData = Req:parse_post(),
    Username = proplists:get_value("email", PostData),
    Password = proplists:get_value("password", PostData),

    %% TODO
    %% Пустые имя пользователя или пароль

    case user:auth(Username, Password) of
        true ->
            auth:login(Username),
            header:redirect(Req, "/");
        false ->
            render_ok(Req, auth_dtl)
    end.
