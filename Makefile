NAME		:= epgsql
VERSION		:= 1.0

ERL  		:= erl
ERLC 		:= erlc

# ------------------------------------------------------------------------

ERLC_FLAGS	:= -Wall -I include

SRC			:= $(wildcard src/*.erl)
TESTS 		:= $(wildcard test_src/*.erl)
RELEASE		:= $(NAME)-$(VERSION).tar.gz

APPDIR		:= $(NAME)-$(VERSION)
BEAMS		:= $(SRC:src/%.erl=ebin/%.beam) 
ERLANGDIR	:= /usr/local/lib/erlang/lib/

compile: $(BEAMS)

app: compile
	@mkdir -p $(APPDIR)/ebin
	@cp -r ebin/* $(APPDIR)/ebin/
	@cp -r include $(APPDIR)

install: app
	@cp -r $(APPDIR) $(ERLANGDIR)

release: app
	@tar czvf $(RELEASE) $(APPDIR)

clean:
	@rm -f ebin/*.beam
	@rm -rf $(NAME)-$(VERSION) $(NAME)-*.tar.gz

test: $(TESTS:test_src/%.erl=test_ebin/%.beam) $(BEAMS)
	dialyzer --src -c src
	$(ERL) -pa ebin/ -pa test_ebin/ -noshell -s pgsql_tests run_tests -s init stop

# ------------------------------------------------------------------------

.SUFFIXES: .erl .beam
.PHONY:    app compile clean test

ebin/%.beam : src/%.erl
	$(ERLC) $(ERLC_FLAGS) -o $(dir $@) $<

test_ebin/%.beam : test_src/%.erl
	$(ERLC) $(ERLC_FLAGS) -o $(dir $@) $<
