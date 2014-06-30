%%%-------------------------------------------------------------------
%%% @author topas
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. июн 2014 3:46
%%%-------------------------------------------------------------------
-module(group_controller).
-author("topas").

%% API
-export([add/2]).

add(_, {raw, []}) ->
    {error, "Groups required"};

add({guest}, {raw, Emails}) ->
    Addresses = parse({list, Emails}),
    add({guest}, {addr, Addresses});

add(_, {Addresses, []}) ->
    {error, "Groups required"};

add({guest}, {addr, Addresses}) ->
    [Author | _] = Addresses,
    add(Author, {addr, Addresses});

add({_, Author}, T) ->
    add(Author, T);

add(Author, {addr, Addresses}) ->

    Users = [user:add({guest, X}) || X <- Addresses],
    GroupName = "self",
    GroupUid = groups:create({group, GroupName, user:key(Author)}),

    [groups:add({group, User}, GroupUid) || User <- Users],

    {ok, GroupUid}.

parse({list, Addresses}) ->
    [parse(X) || X <- Addresses];

parse(RawAddress) ->

    Address = string:strip(RawAddress),

    case re:run(Address, "^[\\d\\s\\+]+$") of
        {match, _} ->
            Phone = re:replace(Address, "[\\s\\+]+", "", [{return, list}, global]),
            {phone, Phone};
        nomatch ->
            {email, Address}
    end.
