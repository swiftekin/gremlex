defmodule Gremlex.Client do
  require Logger
  alias Gremlex.Request
  @mimetype "application/json"

  def start_link([host, port, path]) do
    socket = Socket.Web.connect!(host, port, path: path)
    GenServer.start_link(__MODULE__, socket, [])
  end

  def init(socket) do
    state = %{socket: socket}
    {:ok, state}
  end

  # Public Methods

  @doc """
  Accepts a graph which it converts into a query and queries the database.
  """
  @spec query(Gremlex.Graph.t()) :: map()
  def query(query) do
    payload =
      query
      |> Request.new()
      |> Poison.encode!()

    mime_type_length = <<String.length(@mimetype)>>
    message = mime_type_length <> @mimetype <> payload
    Logger.debug("message: #{message}")

    :poolboy.transaction(:gremlex, fn worker_pid ->
      GenServer.call(worker_pid, {:query, payload})
    end)
  end

  # Private Methods

  def handle_call({:query, payload}, _from, %{socket: socket} = state) do
    Socket.Web.send!(socket, {:text, payload})

    case Socket.Web.recv!(socket) do
      {:text, data} ->
        {:reply, Poison.decode!(data), state}

      {:ping, _} ->
        Socket.Web.send!(socket, {:pong, ""})
    end
  end
end
