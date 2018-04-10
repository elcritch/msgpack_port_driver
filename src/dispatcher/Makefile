
SRC=$(wildcard *.cpp)
OBJ=$(SRC:.cpp=.o)

.PHONY: all clean

DEFAULT_TARGETS = libdispatcher.a libdispatcher.so

LDFLAGS +=
CFLAGS += -fPIC -I. -Irpclib/include/ -Irpclib/include/rpc/msgpack/ -Irpclib/dependencies/include/
CDEFINES += -DRPCLIB_MSGPACK=clmdep_msgpack -DRPCLIB_FMT=clmdep_fmt 

all: $(DEFAULT_TARGETS)

%.o: %.cpp
	$(CXX) -c $(ERL_CFLAGS) $(CFLAGS) $(CDEFINES) -o $@ $<

%.a: $(OBJ)
	ar -cvq $@ $^

%.so: $(OBJ)
	$(CXX) $^ $(ERL_LDFLAGS) $(LDFLAGS) -shared -o $@

clean:
	rm -f *.o $(DEFAULT_TARGETS)
