defmodule MsgpackPortDriver.MixProject do
  use Mix.Project

  @app :rpclib_port_driver
  @version "0.1.3"

  @description """
  Library for creating C++11 Erlang port drivers using `rpclib`, which is a "Modern rpclib - modern rpclib-rpc for C++".
  """

  def project do
    [
      app: @app,
      version: @version,
      description: @description,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      package: package(),
      compilers: [:elixir_make] ++ Mix.compilers,
      deps: deps()
    ]
  end

  defp package do
    [
      maintainers: ["Jaremy Creechley <creechley@gmail.com>"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/elcritch/#{@app}"},
      files: ["lib/", "README.md", "mix.exs", "config/", "Makefile", "priv/dispatcher.tar.xz"]
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
      {:elixir_make, "~> 0.4", runtime: false},
      {:msgpax, "~> 2.0"},
    ]
  end
end
