PROJECT=cometLoader
DESCRIPTION="Comet loader application"
DEPS=lager mochiweb

all: compile run

run:
	ERL_LIBS=deps erl -pa ebin -s cometLoader

compile:
	rebar compile

full: deps compile

deps:
	rebar get-deps

clean:
	rebar clean skip_deps=true

cleanall:
	rebar clean

