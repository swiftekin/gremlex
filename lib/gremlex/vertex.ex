defmodule Gremlex.Vertex do
  alias Gremlex.Vertex

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
end
