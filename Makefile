PROJECT=reminder
DESCRIPTION="Reminder daemon writer application"
DEPS=lager mochiweb

all: compile run

run:
	ERL_LIBS=deps erl -pa ebin -s reminder

compile:
	./rebar compile

full: deps compile

deps:
	./rebar get-deps

clean:
	./rebar clean skip_deps=true

cleanall:
	./rebar clean

