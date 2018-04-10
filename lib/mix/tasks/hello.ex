defmodule Mix.Tasks.Rpclib.Hello do
  use Mix.Task

  @shortdoc "Simply runs the Hello.say/0 command."
  def run(_) do
    # calling our Hello.say() function from earlier
    IO.puts "hello world"
    IO.puts "\nmix tasks: #{inspect Mix.Task.all_modules()}"
    IO.puts "\nmix config: #{inspect Mix.Project.config()}"
    IO.puts "\nmix deps: #{inspect Mix.Project.deps_paths()}"

  end
end
