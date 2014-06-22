%% @author Mochi Media <dev@mochimedia.com>
%% @copyright 2010 Mochi Media <dev@mochimedia.com>

%% @doc Web server for mochiwebapp.

-module(iforget_web).

-export([start/1, stop/0, loop/2]).

-import(render, [render_ok/3]).


%% External API

start(Options) ->
    {DocRoot, Options1} = get_option(docroot, Options),
    Loop = fun(Req) ->
        ?MODULE:loop(Req, DocRoot)
    end,
    mochiweb_http:start([{name, ?MODULE}, {loop, Loop} | Options1]).

stop() ->
    mochiweb_http:stop(?MODULE).

loop(Req, DocRoot) ->
        "/" ++ Path = Req:get(path),
    try
        auth:auth(Req),

        case Req:get(method) of
            'GET' ->
                case Path of
                    "api/" ++ ApiMethod ->
                        rest_handler:handle({get, ApiMethod, Req});
                    "user/" ++ Method ->
                        auth_handler:handle({get, Method, Req});
                    "" ->
                        QueryStringData = Req:parse_qs(),
                        Username = proplists:get_value("datetime", QueryStringData, iso_fmt:iso_8601_fmt(erlang:localtime())),
                        render_ok(Req, send_form_dtl, [{datetime, Username}]);
                    _ ->
                        Req:serve_file(Path, DocRoot)
                end;
            'POST' ->
                case Path of
                    "api/" ++ ApiMethod ->
                        rest_handler:handle({post, ApiMethod, Req});
                    "user/" ++ Method ->
                        auth_handler:handle({post, Method, Req});
                    _ ->
                        header:send({error, Req})
                end;
            'DELETE' ->
                case Path of
                    "api/" ++ ApiMethod ->
                        rest_handler:handle({delete, ApiMethod, Req});
                    _ ->
                        header:send({error, Req})
                end
        end
    catch
        Type:What ->
            Report = ["web request failed",
                {path, Path},
                {type, Type}, {what, What},
                {trace, erlang:get_stacktrace()}],
            error_logger:error_report(Report),
            %% NOTE: mustache templates need \ because they are not awesome.
            header:send({error, Req})
    end.

%% Internal API

get_option(Option, Options) ->
    {proplists:get_value(Option, Options), proplists:delete(Option, Options)}.
