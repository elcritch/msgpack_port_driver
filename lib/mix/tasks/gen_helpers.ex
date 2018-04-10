
defmodule Rpclib.Gen do

  def parse_options(args, switch_defaults) do

    switch_names = switch_defaults |> Keyword.keys()
    {parsed_opts, _other, errors} = OptionParser.parse(args, switches: switch_names)

    options = (switch_defaults ++ parsed_opts) |> Keyword.new()

    status? =
      if length(errors) > 0 do
        for {switch, _value} <- errors do
          sw_name = String.trim_leading(switch, "-")
          IO.puts("Warning: unknown option: #{sw_name}")

          switch_names
          |> Enum.filter(&(String.jaro_distance(to_string(&1), sw_name) > 0.8))
          |> Enum.each(fn x -> IO.puts("    - Did you mean `#{x}`?\n") end)
        end
        :ok
      else
        :errors
      end

    {status?, options}
  end
end
