defmodule Mix.Tasks.Rpclib.Gen.Makefile do
  use Mix.Task

  @makefile_options [
    cflags: "",
    cxxflags: "-g -std=c++11 -O2 -Wall -Wextra ",
    ldflags: "",
    subdir: "",
    targets: "",
  ]

  @shortdoc "Simply runs the Hello.say/0 command."
  def run(args) do

    {_, make_options, _other} = args |> Rpclib.Gen.parse_options(@makefile_options)

    create_makefile(make_options)
  end

  def create_makefile(make_options) do

    make_options = Keyword.update!(make_options, :targets, &String.split(&1, ~r/[ ,]/))

    unless String.length(String.trim(make_options[:subdir])) > 0 do
      raise "Must provide a subdirectory for rpclib"
    end

    IO.puts("Generating makefile with options:")

    make_options
    |> Enum.map(fn {k, v} -> "\t#{k |> to_string() |> String.upcase()}: #{v}" end)
    |> Enum.each(&IO.puts/1)

    IO.puts("")

    # Make subdir and makefile
    subdir = make_options[:subdir]

    # unless IO.inspect(Path.relative_to_cwd(subdir)) != subdir do
      # raise "Error, path is not relative to current directory. Cowardly refusing to make directory. "
    # end

    # Configuring sub-directory
    File.mkdir_p!(subdir)

    makefile = makefile_template(make_options)
    File.write!("#{subdir}/Makefile", makefile)

  end

  def makefile_template(args) do
    """
    #!/usr/bin/make

    # ----------- Source / Target Configs --------------
    SRC=$(wildcard *.cpp)
    OBJ=$(SRC:.cpp=.o)

    TARGETS= <% for target <- targets do %> $(PREFIX)/<%= target %> <% end %>

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

  def driver_template(args) do
    """

    """
    |> EEx.eval_string(args)
  end
end
