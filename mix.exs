defmodule RpclibPortDriver.MixProject do
  use Mix.Project

  @app :rpclib_port_driver
  @version "0.1.0"

  @description """
  Library for creating C++11 Erlang port drivers using `rpclib`, which is a "Modern rpclib - modern msgpack-rpc for C++".
  """

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      make_executable: "make",
      # compilers: [:elixir_make] ++ Mix.compilers, 
      deps: deps()
    ]
  end

  defp package do
    [
      maintainers: ["Jaremy Creechley <creechley@gmail.com>"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/elcritch/#{@app}"},
      files: ["lib/", "priv/", "README.md", "mix.exs", "config/", "src"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:elixir_make, "~> 0.4", runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
