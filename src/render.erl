-module(render).
-compile(export_all).

%% API
%% -export([]).

render_ok(Req, TemplateModule, Params) ->

    {ok, Output} = TemplateModule:render(Params),
    {ok, Layout} = layout_dtl:render([{content, Output}], [{auto_escape, nil}]),
    % Here we use mochiweb_request:ok/1 to render a reponse
    Req:ok({"text/html", Layout}).
