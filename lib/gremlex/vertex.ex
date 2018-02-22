defmodule Gremlex.Vertex do
  alias Gremlex.Vertex
  alias Gremlex.Http

  @type t :: %Gremlex.Vertex{label: String.t, id: number(), properties: map()}
  @enforce_keys [:label, :id]
  @derive [Poison.Encoder]
  defstruct [:label, :id, :properties]

  def add(%Vertex{label: label, id: id, properties: _props}) do
    request = %{gremlin: "graph.addVertex(label, p1, id, p2)", bindings: %{p1: label, p2: id}}
    Http.post(request)
  end

  def property(vertex_id, key, value) do
    "g.V(#{vertex_id}).property('#{key}', '#{value}')"
    |> Http.build
    |> Http.post
  end
end
