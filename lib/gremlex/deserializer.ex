defmodule Gremlex.Deserializer do
  @moduledoc """
  Deserializer module for deserializing data returned back from Gremlin.
  """
  alias Gremlex.{Edge, Vertex}

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
    Vertex.from_response(value)
  end

  defp deserialize("g:VertexProperty", %{"@type" => type, "@value" => value}),
    do: deserialize(type, value)

  defp deserialize("g:Edge", value) do
    Edge.from_response(value)
  end

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
