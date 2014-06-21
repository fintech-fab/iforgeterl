%%%-------------------------------------------------------------------
%%% @author mart
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. июн 2014 13:01
%%%-------------------------------------------------------------------
-module(notice).
-author("mart").

%% API
-export([get_notices/2]).


get_notices([H | T], RedisConnection) ->
    {ok, Notice} = eredis:q(RedisConnection, ["GET", H]),
        "notice:" ++ Uuid = binary_to_list(H),

    [
        {
            {<<"uuid">>, list_to_binary(Uuid)},
            {<<"notice">>, Notice}
        }
        | get_notices(T, RedisConnection)
    ];
get_notices([], _) ->
    [].
