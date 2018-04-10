defmodule Mix.Tasks.Rpclib.Gen.Makefile do
  use Mix.Task

  @default_options [
    cflags: "",
    cxxflags: "-g -std=c++11 -O2 -Wall -Wextra ",
    ldflags: "",
    target: "./priv",
    projects: "src/",
    gendir: "gen/",
  ]

  @shortdoc "Simply runs the Hello.say/0 command."
  def run(args) do

    switch_names = @default_options |> Keyword.keys()
    {parsed_opts, other, errors} = OptionParser.parse(args, switches: switch_names)

    if length(errors) > 0 do
      for {switch, _value} <- errors do

        sw_name = String.trim_leading(switch, "-")
        IO.puts "Warning: unknown option: #{ sw_name }"

        switch_names
        |> Enum.filter(&(String.jaro_distance(to_string(&1), sw_name) > 0.8))
        |> Enum.each(fn x -> IO.puts "    - Did you mean `#{x}`?\n" end)

      end
    end

    make_options = @default_options ++ parsed_opts |> Keyword.new()
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
    export PROJECTS = <%= projects %>
    export GENDIR= <%= gendir %>

    # ----------- C Compiler Configs --------------
    export LDFLAGS = <%= ldflags %>
    export CFLAGS = <%= cflags %>
    export CXXFLAGS = <%= cxxflags %>

    export TARGET = $(abspath <%= target %>)

    all: priv_dir $(SUBDIRS)

    $(TARGET):
      mkdir -p $(TARGET)/

    $(PROJECTS):
      $(MAKE) -C $@

    clean:
      @for d in $(PROJECTS); do (cd $$d; $(MAKE) clean ); done

    .PHONY: $(PROJECTS)

    """
    |> EEx.eval_string(args)
  end

  def blank?(s) do
    if String.match?(s || "", ~r/^\W*$/), do: s, else: nil
  end
end
