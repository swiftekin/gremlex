defmodule Gremlex.EdgeTests do
  alias Gremlex.{Edge, Vertex}
  use ExUnit.Case

  describe "new/7" do
    test "defaults properties to an empty map when not provided" do
      edge = Edge.new(1, "foo", 2, "bar", 3, "baz")
      assert edge.id == 1
      assert edge.label == "foo"
      assert edge.in_vertex == %Vertex{id: 2, label: "bar"}
      assert edge.out_vertex == %Vertex{id: 3, label: "baz"}
      assert edge.properties == %{}
    end
  end
end
