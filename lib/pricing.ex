defmodule Pricing do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # List all child worker processes to be supervised
    children = [
      worker(Pricing.Repo, []),
      worker(Pricing.Scheduler, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pricing.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
