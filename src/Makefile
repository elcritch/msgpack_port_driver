#!/usr/bin/make

# ----------- Source / Target Configs --------------
SRC=$(wildcard *.cpp)
OBJ=$(SRC:.cpp=.o)

TARGETS= 

# ----------- Compiler Configs --------------
LDFLAGS  += 
CFLAGS   += 
CXXFLAGS += -g -std=c++11 -O2 -Wall -Wextra 

# ----------- Make Rules --------------
all: $(DEFAULT_TARGETS)

%.o: %.c
	$(CC) -c $(CFLAGS) $(CDEFS) -o $@ $<

%.o: %.cpp
	$(CXX) -c $(CXXFLAGS) $(CDEFS) -o $@ $<


$(PREFIX)/rpclib_driver: $(OBJ)
	$(CXX) $^ $(ERL_LDFLAGS) -o $@ $(LDFLAGS)


clean:
	rm -f $(OBJ)
	rm -f $(TARGETS)

.PHONY: all clean

