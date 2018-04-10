defmodule Mix.Tasks.Rpclib.Gen.Makefile do
  use Mix.Task

  @makefile_options [
    cflags: "",
    cxxflags: "-g -std=c++11 -O2 -Wall -Wextra ",
    ldflags: "",
    target: "./priv",
    subdirs: "src/",
    gendir: "gen/",
  ]

  @shortdoc "Simply runs the Hello.say/0 command."
  def run(args) do

    switch_names = @makefile_options |> Keyword.keys()
    {parsed_opts, _other, errors} = OptionParser.parse(args, switches: switch_names)

    if length(errors) > 0 do
      for {switch, _value} <- errors do

        sw_name = String.trim_leading(switch, "-")
        IO.puts "Warning: unknown option: #{ sw_name }"

        switch_names
        |> Enum.filter(&(String.jaro_distance(to_string(&1), sw_name) > 0.8))
        |> Enum.each(fn x -> IO.puts "    - Did you mean `#{x}`?\n" end)

      end
    end

    make_options = @makefile_options ++ parsed_opts |> Keyword.new()
    make_options =
      Keyword.update!(make_options, :subdirs, &(String.split(&1, ~r/[ ,]/)) )

    IO.puts "Generating makefile with options:"
    make_options |> Enum.map(fn {k,v} -> "\t#{k |> to_string() |> String.upcase()}: #{v}" end) |> Enum.each(&IO.puts/1)
    IO.puts ""

    makefile = makefile_template(make_options)

    File.write!("./Makefile", makefile)
  end

  def makefile_template(args) do
    """
    #!/usr/bin/make

    # ----------- Makefile Configs   --------------
    export SUBDIRS = <%= subdirs %>
    export GENDIR= <%= gendir %>

    # ----------- C Compiler Configs --------------
    export LDFLAGS = <%= ldflags %>
    export CFLAGS = <%= cflags %>
    export CXXFLAGS = <%= cxxflags %>

    export TARGET = $(abspath <%= target %>)

    all: $(TARGET) $(SUBDIRS)

    $(TARGET):
    \tmkdir -p $(TARGET)/

    $(SUBDIRS):
    \t$(MAKE) -C $@

    clean:
    \t@for d in $(SUBDIRS); do (cd $$d; $(MAKE) clean ); done

    .PHONY: $(SUBDIRS)

    """
    |> EEx.eval_string(args)
  end

end
