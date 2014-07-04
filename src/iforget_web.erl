%% @author Mochi Media <dev@mochimedia.com>
%% @copyright 2010 Mochi Media <dev@mochimedia.com>

%% @doc Web server for mochiwebapp.

-module(iforget_web).

-export([start/1, stop/0, loop/2]).

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
    try
        erlang:put(path, Req:get(path)),
        auth:auth(Req),

        dispatcher:dispatch(Req, DocRoot, [
            {"", {controller, index}, {action, index}},
            {"user/", {controller, user}, {action, index}},
            {"user/signup", {controller, user}, {action, signup}},
            {"user/logout", {controller, user}, {action, logout}},
            {"group/[\\w\\d\\-]+", {controller, group}, {action, index}}
        ])
    catch
        Type:What ->
            Report = ["web request failed",
                {path, Req:get(path)},
                {type, Type}, {what, What},
                {trace, erlang:get_stacktrace()}],
            error_logger:error_report(Report),
            %% NOTE: mustache templates need \ because they are not awesome.
            header:send({error, Req})
    end.

%% Internal API

get_option(Option, Options) ->
    {proplists:get_value(Option, Options), proplists:delete(Option, Options)}.


