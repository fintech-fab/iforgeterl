-module(render).
-compile(export_all).

%% API
%% -export([]).

render_ok(Req, TemplateModule, Params, Options) ->
%%     Options = [{header, notice_dtl}];
    {ok, Header} = ?MODULE:getHeader(Options),

    {ok, Output} = TemplateModule:render(Params),
    {ok, Layout} = layout_dtl:render([{content, Output}, {header, Header}, {leftsize, 1}, {rightsize, 1}, {mainsize, 10}], [{auto_escape, nil}]),

    Req:ok({"text/html", Layout}).

render_ok(Req, TemplateModule, Params) ->
    render_ok(Req, TemplateModule, Params, []).


render_ok(Req, TemplateModule) ->
    render_ok(Req, TemplateModule, [], []).

render_file(Req, send_form_dtl) ->
    Req:serve_file("index.html", "wwwroot");

render_file(Req, TemplateModule) ->
    FileName = erlang:atom_to_list(TemplateModule) ++ ".html",
    Req:serve_file(FileName, "wwwroot").

getHeader(Options) ->
    HeaderName = lists:keyfind(header, 1, Options),

    case HeaderName of
        false ->
            {ok, ""};
        _ ->
            {_, Template} = HeaderName,
            Template:render()
    end.

