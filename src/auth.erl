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
-export([auth/1, login/1, get/0]).

auth(Req) ->
    Cookie = cookie:get(Req, "sess", undefined),

    case Cookie of
        undefined ->
            erlang:put(user, []),
            void;
        _ ->
            Session = session:get({session, Cookie}),
            case Session of
                [] ->
                    erlang:put(user, []),
                    void;
                _ ->
                    [{user, User}] = Session,
                    erlang:put(user, [User])
            end
    end.

get() ->
    case erlang:get(user) of
        [] ->
            {guest};
        undefined ->
            {guest};
        Username ->
            {auth, Username}
    end.

login(Username) ->
    Session = session:start({user, Username}),
    cookie:set("sess", Session),
    Session.
