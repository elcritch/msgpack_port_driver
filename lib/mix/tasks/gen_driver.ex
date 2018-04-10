defmodule Mix.Tasks.Rpclib.Gen.Driver do
  use Mix.Task
  alias Mix.Tasks.Rpclib.Gen.Makefile

  @driver_options [
    subdir: "src/",
    targets: "rpclib_driver",
  ]

  @shortdoc "Simply runs the Hello.say/0 command."
  def run(args) do

    {_, driver_options, _other} = args |> Rpclib.Gen.parse_options(@driver_options)

    cflags = "-Idispatcher/include -D"
    cxxflags = "-std=c++11 #{cflags}"
    ldflags = "-Ldispatcher/ -llibdispatcher"
    subdir = driver_options[:subdir]

    driver_options =
      driver_options
      |> Keyword.put_new(:cflags, cflags)
      |> Keyword.put_new(:cxxflags, cxxflags)
      |> Keyword.put_new(:ldflags, ldflags)

    Makefile.create_makefile(driver_options)

    # Write basic rpclib driver
    driver = driver_template(driver_options)
    File.write!("#{subdir}/rpclib_driver.cpp", driver)

    # Link rpclib deps
    dep_path =
      Mix.Project.deps_paths()[:rpclib_port_driver]
      |> Path.relative_to_cwd()
      |> &(&1 <> "/src").()

    dep_path =
      case Path.type(dep_path) do
        :absolute -> dep_path
        :relative -> "../" <> dep_path
      end

    IO.puts "linking `#{subdir}/dispatcher/` to rpclib dep_path: #{inspect dep_path}"
    File.ln_s!(dep_path, subdir <> "/dispatcher")

  end


  def driver_template(args) do
    """
    #define ERL_PORT_DEBUG

    #include "dispatcher/dispatcher.h"
    #include "dispatcher/erl_comm.hpp"

    #include <string>
    #include <iostream>

    /* port_driver */

    #define PORT_BUFFER_SIZE 8192 //
    typedef uint16_t PacketSize; // Packet Len == 2
    typedef rpc::detail::dispatcher Dispatcher;

    /* rpc example functions */
    std::string foo() {
      // be careful to have _all_ debugging / info output to stderr or a log file
      // otherwise, the erlang port driver _will hang_
      std::cerr << "`foo` was called!" << std::endl;

      return std::string("test");
    }

    int bar(int x, int y) {
      std::cerr << "`bar`` was called! Adding: " << x << " and " << y << std::endl;

      int r = x + y;
      return r;
    }

    int main() {

      std::cerr << "rpc driver started" << std::endl;

      // Configure dispatcher
      Dispatcher dispatcher;
      dispatcher.bind("foo", &foo);
      dispatcher.bind("bar", &bar);

      // Start erl_comm port driver loop
      // Notes: Uses a static buffer and not thread safe
      return port_cmd_loop<Dispatcher, PacketSize, PORT_BUFFER_SIZE>(dispatcher);
    }

    """
    |> EEx.eval_string(args)
  end
end
