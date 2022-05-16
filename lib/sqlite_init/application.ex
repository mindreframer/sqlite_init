defmodule SqliteInit.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # ConnectionListener MUST be started before the Sqlite Repo!
      {SqliteInit.ConnectionListener, SqliteInit.ConnectionListener},
      SqliteInit.Repo,
      SqliteInitWeb.Telemetry,
      {Phoenix.PubSub, name: SqliteInit.PubSub},
      SqliteInitWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SqliteInit.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SqliteInitWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
