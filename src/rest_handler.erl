%%%-------------------------------------------------------------------
%%% @author mart
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. июн 2014 17:43
%%%-------------------------------------------------------------------
-module(rest_handler).
-author("mart").

%% API
-export([handle/1]).

handle({get, "notice/", Req}) ->

    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode(notice:get_all())
    });

handle({get, "notice/" ++ NoticeUuid, Req}) ->
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode(notice:get({notice_uuid, NoticeUuid}))
    });

handle({get, "group/" ++ Uuid, Req}) ->
    Group = groups:get(Uuid),
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode(Group)
    });

handle({post, "group/add/" ++ Uuid, Req}) ->
    PostData = Req:parse_post(),
    Username = proplists:get_value("username", PostData),
    groups:add({group, Username}, Uuid),
    Group = groups:get(Uuid),
    io:write(Group),

    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"uuid">>, Group}])
    });

handle({post, "group", Req}) ->
    PostData = Req:parse_post(),

    Name = proplists:get_value("name", PostData),
%%     Username = proplists:get_value("username", PostData),

    Username = erlang:get(user),
    Author = "user:" ++ Username,
    Uuid = groups:create({group, Name, Author}),

    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"group">>, list_to_binary(Uuid)}])
    });




handle({get, "user/address/" ++ Uuid, Req}) ->

    User = user:get_address(Uuid),
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"ok">>, <<"ok">>}, {<<"user">>, list_to_binary(User)}])
    });
handle({post, "user/address/" ++ Uuid, Req}) ->
    PostData = Req:parse_post(),
    Email = proplists:get_value("email", PostData),
    Phone = proplists:get_value("phone", PostData),

    User = user:set_address({address, Email, Phone}, Uuid),

    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"ok">>, <<"ok">>}, {<<"user">>, list_to_binary(User)}])
    });


handle({get, "user/" ++ Uuid, Req}) ->

    User = user:get({user, Uuid}),
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"ok">>, <<"ok">>}, {<<"user">>, User}])
    });




handle({post, "user", Req}) ->
    PostData = Req:parse_post(),

    Username = proplists:get_value("username", PostData),
    Password = proplists:get_value("password", PostData),

    Uuid = user:add({
        user,
        Username,
        Password
    }),
    case Uuid of
        []->
            Req:respond({
                200,
                [{"Content-Type", "application/json"}],
                []
            });
        _->
            user:set_address({address, Username, <<"">>}, Uuid),
            auth:login(Username),
            header:json({ok, Req}, Uuid)
    end;


handle({post, "notice/", Req}) ->
    QueryStringData = Req:parse_post(),
    %% [{"datetime",Datetime},{"group",Group,{"notice",Text}] = QueryStringData,
    Text = proplists:get_value("notice", QueryStringData),
    Datetime = proplists:get_value("datetime", QueryStringData),
    Group = proplists:get_value("group", QueryStringData),

%%     Username = erlang:get(user),
    Username = 312321,
    GroupName = "default",
    GroupUid = groups:create({group,GroupName,Username}),
    Emails = string:tokens(Group,","),
    lists:foreach(fun(H)->
        Email = user:add({user,H,""}),
        groups:add({group,Email},GroupUid)
    end, Emails),


    [NoticeUuid, NoticesUuid] = notice:add({notice, GroupUid, Datetime, Text}),

    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{ok, ok}, {notice_uuid, NoticeUuid}, {notices_uuid, NoticesUuid}])
    });

handle({delete, "notice/" ++ NoticeUuid, Req}) ->
    Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        mochijson2:encode(notice:remove({notice_uuid, NoticeUuid}))
    });


handle({_, _, Req}) ->
    Req:respond({
        404,
        [{"Content-Type", "application/json"}],
        mochijson2:encode([{<<"error">>, <<"unknown method">>}])
    }).

