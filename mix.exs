defmodule Matreex.MixProject do
  use Mix.Project

  def project do
    [
      app: :matreex,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Matreex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_termbox, "~> 1.0"},
    ]
  end

  defp aliases do
    [
      run: "run_no_halt"
    ]
  end
end
