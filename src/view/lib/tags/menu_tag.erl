%%%-------------------------------------------------------------------
%%% @author topas
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. июл 2014 10:55
%%%-------------------------------------------------------------------
-module(menu_tag).
-author("topas").
-behaviour(erlydtl_library).

%% API
-export([menu/1, version/0, inventory/1]).

%% --------------------------------------------------------------------
%% Definitions
%% --------------------------------------------------------------------


version() -> 1.
inventory(tags) -> [menu];
inventory(filters) -> [].

menu([]) ->

    Menu = [
        [{href, "/"}, {title, <<"главная"/utf8>>}],
        [{href, "#"}, {title, <<"контакты"/utf8>>}],
        [{href, "#"}, {title, <<"помощь"/utf8>>}]
    ],

    User = auth:get(),
    Link = profile_link(User),

    {ok, Content} = menu_dtl:render([{buttons, Menu ++ Link}, {url_path, erlang:get(path)}]),
    Content.

profile_link({auth, Username}) ->
    [
        [{href, "#"}, {title, Username}, {items, [
            [{href, "#"}, {title, <<"просмотреть профиль"/utf8>>}],
            [{href, "#"}, {title, <<"настройки"/utf8>>}],
            [],
            [{href, "/user/logout"}, {title, <<"выйти"/utf8>>}]
        ]}]
    ];

profile_link({guest}) ->
    [
        [{href, "#"}, {title, <<"профиль"/utf8>>}, {items, [
            [{href, "/user/"}, {title, <<"войти"/utf8>>}],
            [{href, "/user/signup/"}, {title, <<"регистрация"/utf8>>}]
        ]}]
    ].
