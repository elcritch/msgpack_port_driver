defmodule MsgpackPortDriver do
  @moduledoc """
  Documentation for MsgpackPortDriver.

  ## About

  The Erlang port drivers are somewhat tedious and adding new functions requires ensuring arguments are defined correectly. This project builds on the very handy [rpclib](http://rpclib.net/) which utilizes modern C++11 features to automatically find functions. Functions can be directly bound or lambda functions can be provided. Most basic C/C++ types are handled and automatically cast. See [RPCLib: What Does it Look like?](http://rpclib.net/#what-does-it-look-like) and [RPCLib: Using custom types as parameters](http://rpclib.net/primer/#using-custom-types-as-parameters) 

  The networking / socket stack has been removed and replaced with a very simple stdio based driver. The driver can be found in the `erl_comm.hpp` header. It listens on `stdin` and parses the Erlang ports communication protocol (it's a very simple protocol and worth reading `erl_comm.hpp` file or Erlang port documentation). 

  ## Examples

  C++ example:

  ```

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

  """

end
