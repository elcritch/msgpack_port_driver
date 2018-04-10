# RpclibPortDriver

Library for creating C++11 Erlang port drivers using `rpclib`, which is a "Modern rpclib - modern msgpack-rpc for C++".

## Installation

```elixir
def deps do
  [
    {:rpclib_port_driver, "~> 0.1.0-alpha"} # usable but may require tinkering
  ]
end
```

## Setup

This library provides a `Mix.Task` for setting up an appropriate Makefile and `rpclib_driver.cpp` file. 

After adding to your dependencies and downloaing, run:

```sh
mix rpclib.gen.project --subdirs=src/
```

```sh
mix rpclib.gen.driver --subdir=src/
```

Note: The first step is not necessary if you already have a Makfile in your project.

These Mix tasks create a simple Makefile and setup a link to the appropriate dependency paths. It should be possible to update the `dispatcher` library code by updating this library in your mix dependencies. 

## Why?

The Erlang port drivers are somewhat tedious and adding new functions requires ensuring arguments are defined correectly. This project builds on the very handy [rpclib](http://rpclib.net/) which utilizes modern C++11 features to automatically find functions. Functions can be directly bound or lambda functions can be provided. Most basic C/C++ types are handled and automatically cast. See [RPCLib: What Does it Look like?](http://rpclib.net/#what-does-it-look-like) and [RPCLib: Using custom types as parameters](http://rpclib.net/primer/#using-custom-types-as-parameters) 

The networking / socket stack has been removed and replaced with a very simple stdio based driver. The driver can be found in the `erl_comm.hpp` header. It listens on `stdin` and parses the Erlang ports communication protocol (it's a very simple protocol and worth reading `erl_comm.hpp` file or Erlang port documentation). 

## Example

```c++

/* rpc example functions */
int bar(int x, int y) {
  std::cerr << "`bar`` was called! Adding: " << x << " and " << y << std::endl;

  int r = x + y;
  return r;
}

int main() {
  // Configure dispatcher
  Dispatcher dispatcher;
  dispatcher.bind("bar", &bar);
  dispatcher.bind("echo", [](std::string const& s) {return std::string("> ") + s;});

  // Start erl_comm port driver loop
  // Notes: Uses a static buffer and not thread safe
  return port_cmd_loop<Dispatcher, PacketSize, PORT_BUFFER_SIZE>(dispatcher);
}
```

On the Elixir side:

```elixir

0 = MyProject.Rpclib.call_port({:bar, [10, -10]})

msg = "hello world"
^msg = MyProject.Rpclib.call_port({:echo, [msg]})
```

## Current Limitations

- WIP! No tests currently (though working on them)
- The port driver is _not_ thread safe
- Do _not_ print / write / std::cout anything to `stdout`.
    + Any messages will cause the port driver to error and usually hang indefinitely. 
- Exception handling is currently not handled well (at all?)


