defmodule Gtd.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GtdWeb.Telemetry,
      Gtd.Repo,
      {DNSCluster, query: Application.get_env(:gtd, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Gtd.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Gtd.Finch},
      # Start a worker by calling: Gtd.Worker.start_link(arg)
      # {Gtd.Worker, arg},
      # Start to serve requests, typically the last entry
      GtdWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gtd.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GtdWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
