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

    ?MODULE:dispatch(Req:get(path), Req, DocRoot, HandledUrl).


%% Выполняем запрос к апи
dispatch(?ApiPrefix ++ Path, Req, _DocRoot, _HandledUrl) ->
    dispatch({api, Path, Req});

%% Ищем урл среди контроллеров
dispatch("/" ++ Path, Req, DocRoot, HandledUrl) ->
    dispatch({controller, Path, Req, DocRoot, HandledUrl}).


%% Запрос к апи
dispatch({api, Path, Req}) ->
    L = string:tokens(Path, "/"),
    RestParams = parse_url(L),
    ControllerName = get_controller_name(RestParams),
    start_controller(ControllerName, get_method(Req:get(method)), RestParams, Req);

%% Запрос к контроллеру
dispatch({controller, Path, Req, DocRoot, HandledUrl}) ->
    Method = Req:get(method),
    case handle_user_url(Path, HandledUrl) of
        undefined ->
            Req:serve_file(Path, DocRoot);

        {controller, ControllerName, action, ActionName} ->

            Controller = list_to_atom(ControllerName ++ "_controller"),
            Action = list_to_atom(ActionName),
            Method = Req:get(method),

            case action_exists(Method, Controller, Action) of
                true ->
                    case Method of

                        'POST' ->
                            Controller:Action(post, Req);
                        'GET' ->
                            Controller:Action(Req)
                    end;
                false ->
                    Req:serve_file(Path, DocRoot)
            end
    end.

handle_user_url(Path, []) ->
    UrlInfo = string:tokens(Path, "/"),
    [Controller, Action] = get_info(UrlInfo),
    {controller, Controller, action, Action};

handle_user_url(Path1, [{RegExp1, {controller, HandleController}, {action, HandleAction}} | T]) ->
    RegExp = string:strip(RegExp1, both, $/),
    Path = string:strip(Path1, both, $/),
    Match = re:run(Path, "^" ++ RegExp ++ "$", [global, {capture, all_but_first, list}]),
    case Match of

        {match, []} ->
            UrlInfo = string:tokens(Path, "/"),
            [Controller, Action] = get_info(UrlInfo),

            {controller, Controller, action, Action};

        {match, [MatchList]} ->
            {controller, HandleController, action, HandleAction};

        _ ->
            handle_user_url(Path, T)
    end.

get_controller_action(Ender) ->
    case Ender of
        "" -> index;
        _ -> list_to_atom(Ender)
    end.

get_info([]) ->
    ["index", "index"];

get_info([Controller]) ->
    [Controller, "index"];

get_info([Controller, Action | _]) ->
    [Controller, Action].

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

parse_url(L) ->
    lists:reverse(parse_url(L, [])).

parse_url([], Acc) ->
    Acc;

parse_url([K, V | L], Acc) ->
    parse_url(L, [get_tuple(K, V)] ++ Acc);

parse_url([K | []], Acc) ->
    parse_url([], [get_tuple(K, undefined)] ++ Acc).

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

action_exists(Method, Controller, Action) ->
    ModuleExists = module_exists(Controller),
    action_exists(Method, ModuleExists, Controller, Action).

action_exists(_, false, _, _) ->
    false;

action_exists('POST', true, Controller, Action) ->
    erlang:function_exported(Controller, Action, 2);

action_exists('GET', true, Controller, Action) ->
    erlang:function_exported(Controller, Action, 1).
