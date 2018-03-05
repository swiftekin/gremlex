defmodule Gremlex.VertexProperty do
  @type t :: %Gremlex.VertexProperty{
          label: String.t(),
          id: number(),
          value: any(),
          vertex: number()
        }
  @enforce_keys [:label, :id, :value, :vertex]
  @derive [Poison.Encoder]
  defstruct [:label, :id, :value, :vertex]

  def from_response(%{"id" => json_id, "value" => value, "vertex" => vertex, "label" => label}) do
    %{"@value" => id} = json_id
    %{"@value" => vertex_id} = vertex
    %Gremlex.VertexProperty{label: label, id: id, vertex: vertex_id, value: value}
  end
end
