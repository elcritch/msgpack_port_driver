defmodule Mix.Tasks.Rpclib.Gen.Project do
  use Mix.Task

  @makefile_options [
    cflags: "",
    cxxflags: "-g -std=c++11 -O2 -Wall -Wextra ",
    ldflags: "",
    prefix: "./priv",
    subdirs: "src/",
    objdir: "."
  ]

  @shortdoc "Simply runs the Hello.say/0 command."
  def run(args) do

    {_status, make_options, _other} =
      args |> Rpclib.Gen.parse_options(@makefile_options)

    make_options = Keyword.update!(make_options, :subdirs, &String.split(&1, ~r/[ ,]/))

    IO.puts("Generating makefile with options:")

    make_options
    |> Enum.map(fn {k, v} -> "\t#{k |> to_string() |> String.upcase()}: #{v}" end)
    |> Enum.each(&IO.puts/1)

    IO.puts("")

    makefile = makefile_template(make_options)

    File.write!("./Makefile", makefile)
  end

  def makefile_template(args) do
    """
    #!/usr/bin/make

    # ----------- Makefile Configs --------------

    # add more sub-projects here by adding the relative dir path
    export SUBDIRS  = <%= subdirs %>
    # set object output directories here (relative to file)
    export OBJDIR   = <%= objdir %>

    # ----------- Compiler Configs --------------
    export LDFLAGS  = <%= ldflags %>
    export CFLAGS   = <%= cflags %>
    export CXXFLAGS = <%= cxxflags %>

    export PREFIX = $(abspath <%= prefix %>)

    # ----------- Make Rules --------------
    all: $(PREFIX) $(SUBDIRS)

    $(PREFIX):
    \tmkdir -p $(PREFIX)/

    $(SUBDIRS):
    \t$(MAKE) -C $@

    clean:
    \t@for d in $(SUBDIRS); do (cd $$d; $(MAKE) clean ); done

    .PHONY: $(SUBDIRS)

    """
    |> EEx.eval_string(args)
  end
end
