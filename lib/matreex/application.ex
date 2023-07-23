defmodule Matreex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = if Mix.env() == :test, do: [], else: [
      Matreex
    ]

    opts = [strategy: :one_for_one, name: Matreex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
