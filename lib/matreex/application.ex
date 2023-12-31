defmodule Matreex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = if Application.get_env(:matreex, :start_app, true) do
      [
        Matreex
      ]
    else
      []
    end

    opts = [strategy: :one_for_one, name: Matreex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
