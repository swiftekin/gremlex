defmodule Gremlex.Edge do
  alias Gremlex.Deserializer
  @enforce_keys [:label, :id, :in_vertex, :out_vertex, :properties]
  @derive [Poison.Encoder]
  @type t :: %Gremlex.Edge{
          label: String.t(),
          id: number(),
          properties: map(),
          in_vertex: Gremlex.Vertex.t(),
          out_vertex: Gremlex.Vertex.t()
        }
  defstruct [:label, :id, :in_vertex, :out_vertex, :properties]

  def new(id, label, in_vertex_id, in_vertex_label, out_vertex_id, out_vertex_label) do
    in_vertex = %Gremlex.Vertex{id: in_vertex_id, label: in_vertex_label}
    out_vertex = %Gremlex.Vertex{id: out_vertex_id, label: out_vertex_label}

    %Gremlex.Edge{
      id: id,
      label: label,
      in_vertex: in_vertex,
      out_vertex: out_vertex,
      properties: %{}
    }
  end

  def from_response(value) do
    %{
      "id" => %{"@type" => id_type, "@value" => id_value},
      "inV" => %{"@type" => in_v_id_type, "@value" => in_v_id_value},
      "inVLabel" => in_v_label,
      "label" => label,
      "outV" => %{"@type" => out_v_id_type, "@value" => out_v_id_value},
      "outVLabel" => out_v_label
    } = value

    id = Deserializer.deserialize(id_type, id_value)
    in_v_id = Deserializer.deserialize(in_v_id_type, in_v_id_value)
    out_v_id = Deserializer.deserialize(out_v_id_type, out_v_id_value)

    Gremlex.Edge.new(
      id,
      label,
      in_v_id,
      in_v_label,
      out_v_id,
      out_v_label
    )
  end
end
