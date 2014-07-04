%%%-------------------------------------------------------------------
%%% @author petrov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. июл 2014 9:17
%%%-------------------------------------------------------------------
-module(dispatcher).
-author("petrov").

-define(Resource, "resource").
-define(ApiPrefix, "/api/").
-define(AllowedMethods, [get, post, put, delete, patch, head]).

-compile(export_all).
%% API
-export([]).


dispatch(Req, DocRoot, HandledUrl) ->

  ?MODULE:dispatch(Req:get(path), Req, DocRoot,HandledUrl).



%% Выполняем запрос к апи
dispatch(?ApiPrefix ++ Path, Req, _DocRoot,_HandledUrl) ->
  dispatch({api, Path, Req});

%% Ищем урл среди контроллеров
dispatch("/" ++ Path, Req, DocRoot, HandledUrl) ->
  dispatch({controller,Path, Req, DocRoot, HandledUrl}).


%% Запрос к апи
dispatch({api, Path, Req})->
  L = string:tokens(Path, "/"),
  RestParams = parce_url(L),
  ControllerName = get_controller_name(RestParams),
  start_controller(ControllerName, get_method(Req:get(method)), RestParams, Req);

%% Запрос к контроллеру
dispatch({controller,Path, Req, DocRoot,HandledUrl})->
  case Req:get(method) of
    'GET' ->
      case handle_user_url(Path,Req,HandledUrl) of
        undefined->
          Req:serve_file(Path, DocRoot);
        {controller,Controller,action,Action}->
          ControllerName = list_to_atom(atom_to_list(Controller)++"_controller"),

          case module_exists(ControllerName) of
            true ->
              case erlang:function_exported(ControllerName,Action,1) of
                true->
                  ControllerName:Action(Req);
                  false->
                    header:send({not_found,Req})
              end;
            false ->
              header:send({not_found,Req})

          end

      end
  end.






handle_user_url(_,_,[])
  ->undefined;

handle_user_url(Path1,Req,[{RegExp1,{controller,Controller},{action,Action}}|T])->
  RegExp = string:strip(RegExp1,both,$/),
  Path = string:strip(Path1,both,$/),
  Match = re:run(Path, "^"++RegExp++"$", [global, {capture, all_but_first, list}]),
  case Match of
    {match,[MatchList]}->
      {controller,Controller,action,Action};
    _->
      handle_user_url(Path,Req,T)
  end.



get_controller_action(Ender) ->
  case Ender of
    "" -> index;
    _ -> list_to_atom(Ender)
  end.

%% Запрос экшена к ресурсу
start_controller(Controller, Method, Params, Req) ->
  case ?MODULE:module_exists(Controller) of
    false ->
      header:json({not_found, Req});
    true ->
      execute_action(Controller, Method, Req, Params)
  end.



execute_action(Controller, Method, Req, Params) ->
  {_, Value} = lists:last(Params),
  case Method of
    get when Value /= undefined ->
      execute_action({execute, Controller, Method, Params, Req}, {id, Value});

    put when Value /= undefined ->
      execute_action({execute, Controller, Method, Params, Req}, {id, Value});
    delete when Value /= undefined ->
      execute_action({execute, Controller, Method, Params, Req}, {id, Value});
    get ->
      execute_action({execute, Controller, Method, Params, Req});
    post ->
      execute_action({execute, Controller, Method, Params, Req});

    path ->
      1;
    _ ->
      header:json({not_allowed, Req})


  end.

execute_action({execute, Controller, Method, Params, Req}, {id, Value}) ->

  case erlang:function_exported(Controller, Method, 3) of
    true ->
      Controller:Method(Req, {url_params, Params}, {id, Value});
    _ ->
      header:json({not_allowed, Req})
  end.

execute_action({execute, Controller, Method, Params, Req}) ->
  case erlang:function_exported(Controller, Method, 2) of
    true ->
      Controller:Method(Req, {url_params, Params});
    _ ->
      header:json({not_allowed, Req})
  end.


get_method(Method) ->
  MethodAtom = list_to_atom(string:to_lower(atom_to_list(Method))),
  case lists:member(MethodAtom, ?AllowedMethods) of
    true ->
      MethodAtom;
    false ->
      undefined
  end.


get_controller_name(RestParams) ->
  list_to_atom(lists:foldr(fun({Name, _}, Acc) -> atom_to_list(Name) ++ "_" ++ Acc end, ?Resource, RestParams)).



parce_url(L) ->
  lists:reverse(parce_url(L, [])).
parce_url([], Acc) ->
  Acc;
parce_url([K, V | L], Acc) ->
  parce_url(L, [get_tuple(K, V)] ++ Acc);
parce_url([K | []], Acc) ->
  parce_url([], [get_tuple(K, undefined)] ++ Acc).
get_tuple(Attribute, Value) ->
  {list_to_atom(unicode:characters_to_list(Attribute)), Value}.


module_exists(Module) ->
  case is_atom(Module) of
    true ->
      try Module:module_info() of
        _InfoList ->
          true
      catch
        _:_ ->
          false
      end;

    false ->
      false
  end.