defmodule Gremlex.Vertex do
  alias Gremlex.Vertex
  alias Gremlex.Deserializer

  @type t :: %Gremlex.Vertex{label: String.t(), id: number(), properties: map()}
  @enforce_keys [:label, :id]
  @derive [Poison.Encoder]
  defstruct [:label, :id, :properties]

  def add_properties(%Vertex{properties: nil} = vertex, properties) do
    Map.put(vertex, :properties, properties)
  end

  def add_properties(%Vertex{properties: this} = vertex, that) do
    properties = Map.merge(this, that)
    Map.put(vertex, :properties, properties)
  end

  def add_property(%Vertex{properties: props} = vertex, label, value) do
    properties = Map.put(props, label, value)
    Map.put(vertex, :properties, properties)
  end

  def from_response(%{"id" => json_id, "label" => label, "properties" => properties}) do
    %{"@type" => id_type, "@value" => id_value} = json_id

    id = Deserializer.deserialize(id_type, id_value)

    vertex = %Vertex{id: id, label: label}

    serialized_properties =
      Enum.reduce(properties, %{}, fn {label, [prop]}, acc ->
        %{"@type" => type, "@value" => %{"value" => value}} = prop
        Map.put(acc, String.to_atom(label), Deserializer.deserialize(type, value))
      end)

    Vertex.add_properties(vertex, serialized_properties)
  end
end
