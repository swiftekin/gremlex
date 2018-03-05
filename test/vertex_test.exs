defmodule Gremlex.VertexTests do
  use ExUnit.Case
  alias Gremlex.Vertex

  describe "add_properties/2" do
    test "allows you to add properties to an existing map" do
      vertex = %Vertex{id: 0, label: "foo", properties: %{foo: "bar"}}
      expected_vertex = %Vertex{id: 0, label: "foo", properties: %{foo: "bar", bar: "foo"}}
      assert Vertex.add_properties(vertex, %{bar: "foo"}) == expected_vertex
    end
  end
end
