%% @author Mochi Media <dev@mochimedia.com>
%% @copyright 2010 Mochi Media <dev@mochimedia.com>

%% @doc Web server for mochiwebapp.

-module(iforget_web).

-export([start/1, stop/0, loop/2]).

%% External API

start(Options) ->
    {DocRoot, Options1} = get_option(docroot, Options),
    Loop = fun (Req) ->
                   ?MODULE:loop(Req, DocRoot)
           end,
    mochiweb_http:start([{name, ?MODULE}, {loop, Loop} | Options1]).

stop() ->
    mochiweb_http:stop(?MODULE).

loop(Req, DocRoot) ->
    "/" ++ Path = Req:get(path),
    try
        case Req:get(method) of
            Method when Method =:= 'GET'; Method =:= 'HEAD' ->
                case Path of
                    "hello" ->
                      QueryStringData = Req:parse_qs(),
                      Username = proplists:get_value("username", QueryStringData, "Anonymous"),
                      timer:seconds(1),
                      Req:respond({200, [{"Content-Type", "text/plain"}],
                          "Hello " ++ Username ++ "!\n"});
                    _ ->
                        Req:serve_file(Path, DocRoot)
                end;
            'POST' ->
                case Path of
                    _ ->

                      {ok, C} = eredis:start_link(),
                      QueryStringData = Req:parse_qs(),
                      {ok, <<"OK">>} = eredis:q(C, ["SET", "foo", proplists:get_value("foo", QueryStringData, "test")]),
                      %%io:format("", QueryStringData),
                      Req:respond({200, [{"Content-Type", "text/plain"}],"Hi"})
                end;
            _ ->
                Req:respond({501, [], []})
        end
    catch
        Type:What ->
            Report = ["web request failed",
                      {path, Path},
                      {type, Type}, {what, What},
                      {trace, erlang:get_stacktrace()}],
            error_logger:error_report(Report),
            %% NOTE: mustache templates need \ because they are not awesome.
            Req:respond({500, [{"Content-Type", "text/plain"}],
                         "request failed, sorry\n"})
    end.

%% Internal API

get_option(Option, Options) ->
    {proplists:get_value(Option, Options), proplists:delete(Option, Options)}.