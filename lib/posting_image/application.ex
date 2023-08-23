defmodule PostingImage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PostingImageWeb.Telemetry,
      # Start the Ecto repository
      PostingImage.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: PostingImage.PubSub},
      # Start Finch
      {Finch, name: PostingImage.Finch},
      # Start the Endpoint (http/https)
      PostingImageWeb.Endpoint
      # Start a worker by calling: PostingImage.Worker.start_link(arg)
      # {PostingImage.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PostingImage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PostingImageWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
