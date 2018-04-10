#!/usr/bin/make

# ----------- Makefile Configs --------------

# add more sub-projects here by adding the relative dir path
export SUBDIRS  = src/
# set object output directories here (relative to file)
export OBJDIR   = .

# ----------- Compiler Configs --------------
export LDFLAGS  = 
export CFLAGS   = 
export CXXFLAGS = -g -std=c++11 -O2 -Wall -Wextra 

export PREFIX = $(abspath ./priv)

# ----------- Make Rules --------------
all: $(PREFIX) $(SUBDIRS)

$(PREFIX):
	mkdir -p $(PREFIX)/

$(SUBDIRS):
	$(MAKE) -C $@

clean:
	@for d in $(SUBDIRS); do (cd $$d; $(MAKE) clean ); done

.PHONY: $(SUBDIRS)

