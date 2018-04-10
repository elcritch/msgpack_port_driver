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
    switch_names = @makefile_options |> Keyword.keys()
    {parsed_opts, _other, errors} = OptionParser.parse(args, switches: switch_names)

    if length(errors) > 0 do
      for {switch, _value} <- errors do
        sw_name = String.trim_leading(switch, "-")
        IO.puts("Warning: unknown option: #{sw_name}")

        switch_names
        |> Enum.filter(&(String.jaro_distance(to_string(&1), sw_name) > 0.8))
        |> Enum.each(fn x -> IO.puts("    - Did you mean `#{x}`?\n") end)
      end
    end

    make_options = (@makefile_options ++ parsed_opts) |> Keyword.new()
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

    SRC=$(wildcard *.cpp )
    OBJ=$(SRC:.cpp=.o)

    .PHONY: all clean

    DEFAULT_TARGETS = $(TARGET)/display

    LDFLAGS +=
    CFLAGS += -Idispatcher/include 
    # CFLAGS += -Idispatcher/include -Ishims/ -Ic-periphery/src/ -Iadafruit/ -Iadafruit/gfx/
    CDEFINES += -D__FlashStringHelper=char

    all: $(DEFAULT_TARGETS)

    %.o: %.c
    \t$(CC) -c $(ERL_CFLAGS) $(CFLAGS_SSD) $(CDEFINES) -o $@ $<

    %.o: %.cpp
    \t$(CXX) -c $(ERL_CFLAGS) $(CFLAGS) $(CDEFINES) -o $@ $<

    $(TARGET)/display: $(OBJ)
    \t$(CXX) $^ $(ERL_LDFLAGS) $(LDFLAGS) -o $@ dispatcher/libdispatcher.a ssd1306-bb/lib_bb_display.a

    clean:
    rm -f $(OBJ)
    rm -f $(TARGET)/display


    """
    |> EEx.eval_string(args)
  end
end
