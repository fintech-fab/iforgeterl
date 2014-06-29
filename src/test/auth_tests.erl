%%%-------------------------------------------------------------------
%%% @author topas
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. июн 2014 12:16
%%%-------------------------------------------------------------------
-module(auth_tests).
-author("topas").

-include_lib("eunit/include/eunit.hrl").

%% API
-export([]).

login_test_() ->
    SessionUid = auth:login("TestUser"),

    Session = session:get({session, SessionUid}),
    Username = proplists:get_value(user, Session),

    [
        ?_assert(SessionUid =/= []),
        ?_assert(Session =/= []),
        ?_assert(Username =:= <<"TestUser">>)
    ].
