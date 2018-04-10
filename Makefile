#!/usr/bin/make

# ----------- Make Rules --------------
all: priv/dispatcher

priv/dispatcher:
	tar xvf priv/dispatcher.tar.xz -C priv/

clean:
	@for d in $(SUBDIRS); do (cd $$d; $(MAKE) clean ); done

.PHONY: priv/dispatcher

