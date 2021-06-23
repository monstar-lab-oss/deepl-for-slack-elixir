defmodule DeepThought.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      DeepThought.Repo,
      # Start the Telemetry supervisor
      DeepThoughtWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: DeepThought.PubSub},
      # Start the Endpoint (http/https)
      DeepThoughtWeb.Endpoint,
      # Start a worker by calling: DeepThought.Worker.start_link(arg)
      # {DeepThought.Worker, arg}
      {Task.Supervisor,
       name: DeepThought.TranslatorSupervisor,
       restart: :transient,
       max_restarts: 3,
       max_seconds: 15}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DeepThought.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DeepThoughtWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
