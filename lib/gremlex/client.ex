defmodule Gremlex.Client do
  @moduledoc """
  Gremlin Websocket Client
  """

  require Logger
  alias Gremlex.Request
  alias Gremlex.Deserializer

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

    :poolboy.transaction(:gremlex, fn worker_pid ->
      GenServer.call(worker_pid, {:query, payload})
    end)
  end

  # Server Methods

  def handle_call({:query, payload}, _from, %{socket: socket} = state) do
    Socket.Web.send!(socket, {:text, payload})

    task = Task.async(fn -> recv(socket, []) end)
    result = Task.await(task)

    {:reply, result, state}
  end

  # Private Methods

  defp recv(socket, acc \\ []) do
    case Socket.Web.recv!(socket) do
      {:text, data} ->
        response = Poison.decode!(data)
        result = Deserializer.deserialize(response)
        # Continue to block until we receive a 200 status code
        if response["status"]["code"] == 200 do
          acc ++ result
        else
          result = Deserializer.deserialize(response)
          recv(socket, acc ++ result)
        end

      {:ping, _} ->
        # Keep the connection alive
        Socket.Web.send!(socket, {:pong, ""})
        recv(socket, acc)
    end
  end
end
