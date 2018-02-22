defmodule Gremlex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    host = Confex.fetch_env!(:gremlex, :host)
    pool_size = Confex.fetch_env!(:gremlex, :pool_size)

    pool_options = [
      name: {:local, :gremlex},
      worker_module: Gremlex.Client,
      size: pool_size,
      max_overflow: 10
    ]

    children = [
      :poolboy.child_spec(:gremlex, pool_options, [host])
      # Starts a worker by calling: Gremlex.Worker.start_link(arg)
      # {Gremlex.Worker, arg},
    ]

    # case :hackney_pool.start_pool(:gremlex_pool, [timeout: 15000, max_connections: pool_size]) do
    #   :ok ->
    #     nil
    #   :error ->
    #     raise "Cannot create HTTP request pool"
    # end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gremlex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
