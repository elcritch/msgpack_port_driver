#!/usr/bin/make

# ----------- Make Rules --------------
all: priv/dispatcher

priv/dispatcher:
	tar xvf priv/dispatcher.tar.xz -C priv/

clean:
	rm -Rf priv/dispatcher/

.PHONY: priv/dispatcher

