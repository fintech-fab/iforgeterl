PROJECT=iforget
DESCRIPTION="iforget daemon writer application"
DEPS=lager mochiweb

all: deps compile run

run:
	ERL_LIBS=deps erl -pa ebin edit deps/*/ebin -boot start_sasl -s iforget -s reloader

compile:
	./rebar compile

full: deps compile

deps:
	./rebar get-deps

clean:
	./rebar clean skip_deps=true

cleanall:
	./rebar clean

