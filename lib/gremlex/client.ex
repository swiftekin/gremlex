defmodule Gremlex.Client do
  require Logger
  alias Gremlex.Request
  alias Gremlex.Vertex
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
        result =
          data
          |> Poison.decode!
          |> deserialize

        {:reply, result, state}

      {:ping, _} ->
        Socket.Web.send!(socket, {:pong, ""})
    end
  end

  defp deserialize(response) do
    %{"result" => result} = response
    case result["data"] do
      nil ->
        nil
      %{"@type" => type, "@value" => value} ->
        deserialize(type, value)
    end
  end

  defp deserialize("g:List", value) do
    Enum.map(value, fn
      %{"@type" => type, "@value" => value} ->
        deserialize(type, value)
      value ->
        value
    end)
  end

  defp deserialize("g:Vertex", value) do
    %{"id" => %{"@type" => id_type, "@value" => id_value},
      "label" => label,
      "properties" => properties} = value

    id = deserialize(id_type, id_value)

    vertex = %Vertex{id: id,
                     label: label}

    serialized_properties =
      Enum.reduce(properties, %{}, fn ({label, [prop]}, acc) ->
        %{"@type" => type, "@value" => %{"value" => value}} = prop
        IO.inspect value, label: "@value"
        Map.put(acc, String.to_existing_atom(label), value)
      end)

    Vertex.add_properties(vertex, serialized_properties)
  end

  defp deserialize("g:Int64", value) when is_number(value), do: value

  defp deserialize("g:Int64", value) when is_binary(value) do
    case Integer.parse(value) do
      {val, ""} ->
        val
      :error ->
        0
    end
  end
end
