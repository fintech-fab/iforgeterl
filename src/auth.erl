%%%-------------------------------------------------------------------
%%% @author topas
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. июн 2014 12:12
%%%-------------------------------------------------------------------
-module(auth).
-author("topas").

%% API
-export([auth/1, login/1]).

auth(Req) ->
    Cookie = cookie:get(Req, "sess", undefined),

    case Cookie of
        undefined ->
            void;
        _ ->
            Session = session:get({session, Cookie}),

            case Session of
                [] ->
                    void;
                _ ->
                    [<<"user">>, User] = Session,
                    io:format("User: ~s ~n", [User]),
                    erlang:put(user, [User])
            end
    end
.

login(Username) ->
    io:format("START SESSION~n"),
    Session = session:start({user, Username}),
    cookie:set("sess", Session).
