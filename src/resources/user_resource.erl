%%%-------------------------------------------------------------------
%%% @author petrov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. июл 2014 15:00
%%%-------------------------------------------------------------------
-module(user_resource).
-author("petrov").

-compile(export_all).

%% API
-export([]).



get(Req,{url_params,_Params},{id,Id})->
  User = user:get({user, Id}),
  Req:respond({
    200,
    [{"Content-Type", "application/json"}],
    mochijson2:encode([{<<"ok">>, <<"ok">>}, {<<"user">>, User}])
  }).


post(Req,{url_params,_Params})->
  PostData = Req:parse_post(),

  Username = proplists:get_value("username", PostData),
  Password = proplists:get_value("password", PostData),

  Uuid = user:add({
    user,
    string:strip(Username),
    Password
  }),
  case Uuid of
    [] ->
      Req:respond({
        200,
        [{"Content-Type", "application/json"}],
        []
      });
    _ ->
      user:set_address({email, Username}, Uuid),
      auth:login(Username),
      header:json({ok, Req}, Uuid)
  end.



