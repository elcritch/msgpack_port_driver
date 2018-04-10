#!/usr/bin/make

# ----------- Makefile Configs   --------------
export SUBDIRS = src/
export GENDIR= test/

# ----------- C Compiler Configs --------------
export LDFLAGS = 
export CFLAGS = 
export CXXFLAGS = -g -std=c++11 -O2 -Wall -Wextra 

export TARGET = $(abspath ./priv)

all: priv_dir $(SUBDIRS)

$(TARGET):
  mkdir -p $(TARGET)/

$(SUBDIRS):
  $(MAKE) -C $@

clean:
  @for d in $(SUBDIRS); do (cd $$d; $(MAKE) clean ); done

.PHONY: $(SUBDIRS)

