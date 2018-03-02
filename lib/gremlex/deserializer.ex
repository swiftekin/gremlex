defmodule Gremlex.Deserializer do
  @moduledoc """
  Deserializer module for deserializing data returned back from Gremlin.
  """
  alias Gremlex.Vertex

  def deserialize(response) do
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

  defp deserialize("g:Set", value) do
    Enum.map(value, fn
      %{"@type" => type, "value" => value} ->
        deserialize(type, value)

      value ->
        value
    end)
  end

  defp deserialize("g:Vertex", value) do
    %{
      "id" => %{"@type" => id_type, "@value" => id_value},
      "label" => label,
      "properties" => properties
    } = value

    id = deserialize(id_type, id_value)

    vertex = %Vertex{id: id, label: label}

    serialized_properties =
      Enum.reduce(properties, %{}, fn {label, [prop]}, acc ->
        %{"@type" => type, "@value" => %{"value" => value}} = prop
        Map.put(acc, String.to_atom(label), deserialize(type, value))
      end)

    Vertex.add_properties(vertex, serialized_properties)
  end

  defp deserialize("g:VertexProperty", %{"@type" => type, "@value" => value}),
    do: deserialize(type, value)

  defp deserialize("g:Int64", value) when is_number(value), do: value

  defp deserialize("g:Int32", value), do: value

  defp deserialize("g:Double", value) when is_number(value), do: value

  defp deserialize("g:Float", value) when is_number(value), do: value

  defp deserialize("g:UUID", value), do: value

  defp deserialize("g:Date", value) do
    DateTime.from_unix!(value, :microsecond)
  end

  defp deserialize("g:Timestamp", value) do
    DateTime.from_unix!(value, :microsecond)
  end

  defp deserialize("g:Int64", value) when is_binary(value) do
    case Integer.parse(value) do
      {val, ""} ->
        val

      :error ->
        0
    end
  end

  defp deserialize(_type, value), do: value
end
