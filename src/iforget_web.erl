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
    "/" ++ Path = Req:get(path),
  try
    case Req:get(method) of
      'GET' ->
        case Path of
          "api/" ++ ApiMethod ->
            rest_handler:handle({get, ApiMethod, Req});
          _ ->
            Req:serve_file(Path, DocRoot)
        end;
      'POST' ->
        case Path of
        %%                "api/" ++ ApiMethod ->
%%                  rest_handler:handle({post,ApiMethod,Req})
%%              end;

          "api/message" ->
            QueryStringData = Req:parse_qs(),
            Text = proplists:get_value("text", QueryStringData, "tets"),
            {ok, C} = eredis:start_link(),
            MessageUuid = uuid:to_string(uuid:uuid4()),
            {ok, <<"OK">>} = eredis:q(C, ["SET", "message:" ++ MessageUuid, Text]),

            Req:respond({200, [{"Content-Type", "text/plain"}], "ok"});

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
