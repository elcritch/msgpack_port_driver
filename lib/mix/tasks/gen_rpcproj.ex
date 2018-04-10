defmodule Mix.Tasks.Rpclib.Gen.Rpclib do
  use Mix.Task

  @makefile_options [
    cflags: "",
    cxxflags: "-g -std=c++11 -O2 -Wall -Wextra ",
    ldflags: "",
    target: "./priv",
    subdirs: "src/",
    gendir: "gen/"
  ]

  @shortdoc "Simply runs the Hello.say/0 command."
  def run(args) do

    {_, make_options} = args |> Rpclib.Gen.parse_options(@makefile_options)

    make_options = Keyword.update!(make_options, :subdirs, &String.split(&1, ~r/[ ,]/))

    IO.puts("Generating makefile with options:")

    make_options |> Enum.map(fn {k, v} -> "\t#{k |> to_string() |> String.upcase()}: #{v}" end)
    |> Enum.each(&IO.puts/1)

    IO.puts("")

    makefile = makefile_template(make_options)

    File.write!("./Makefile", makefile)
  end

  def makefile_template(args) do
    """
    #!/usr/bin/make

    # ----------- Source / Target Configs --------------
    SRC=$(wildcard *.cpp)
    OBJ=$(SRC:.cpp=.o)

    TARGETS= <%= for target <- targets do %> $(PREFIX)/<% target %> <% end %>

    # ----------- Compiler Configs --------------
    LDFLAGS  += <%= ldflags %>
    CFLAGS   += <%= cflags %>
    CXXFLAGS += <%= cxxflags %>

    # ----------- Make Rules --------------
    all: $(DEFAULT_TARGETS)

    %.o: %.c
    \t$(CC) -c $(CFLAGS) $(CDEFS) -o $@ $<

    %.o: %.cpp
    \t$(CXX) -c $(CXXFLAGS) $(CDEFS) -o $@ $<

    <%= for target <- targets do %>
    $(PREFIX)/<%= target %>: $(OBJ)
    \t$(CXX) $^ $(ERL_LDFLAGS) -o $@ $(LDFLAGS)
    <% end %>

    clean:
    \trm -f $(OBJ)
    \trm -f $(TARGETS)

    .PHONY: all clean

    """
    |> EEx.eval_string(args)
  end
end
