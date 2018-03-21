defmodule Gremlex.GraphTests do
  import Gremlex.Graph
  alias Gremlex.{Vertex, Graph}
  use ExUnit.Case
  use ExUnitProperties
  alias :queue, as: Queue

  describe "g/0" do
    test "returns a new queue" do
      assert g() == Queue.new()
    end
  end

  describe "add_v/1" do
    test "adds an addVertex function to the queue" do
      actual_graph = g() |> add_v(1)
      expected_graph = Queue.in({"addV", [1]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "add_e/1" do
    test "adds an addE step to the queue" do
      actual_graph = g() |> add_e("foo")
      expected_graph = Queue.in({"addE", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "has_label/1" do
    test "adds a hasLabel function to the queue" do
      actual_graph = g() |> has_label("foo")
      expected_graph = Queue.in({"hasLabel", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "has/3" do
    test "adds a has function to the queue" do
      actual_graph = g() |> has("foo", "bar")
      expected_graph = Queue.in({"has", ["foo", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "property/3" do
    test "adds a property function to the queue" do
      actual_graph = g() |> Graph.property("foo", "bar")
      expected_graph = Queue.in({"property", ["foo", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "values/2" do
    test "adds a value function the queue" do
      actual_graph = g() |> values("foo")
      expected_graph = Queue.in({"values", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "v/1" do
    test "adds a V function to the queue" do
      actual_graph = g() |> v()
      expected_graph = Queue.in({"V", []}, Queue.new())
      assert actual_graph == expected_graph
    end

    test "creates a vertex when the id is a number" do
      check all n <- integer() do
        actual_graph = v(n)
        expected_graph = %Vertex{id: n, label: ""}
        assert actual_graph == expected_graph
      end
    end
  end

  describe "v/2" do
    test "adds a V function for an id to the queue" do
      actual_graph = g() |> v(1)
      expected_graph = Queue.in({"V", [1]}, Queue.new())
      assert actual_graph == expected_graph
    end

    test "adds a V function when given a vertex to the queue" do
      actual_graph = g() |> v(%Vertex{id: 1, label: "foo"})
      expected_graph = Queue.in({"V", [1]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "out_e/2" do
    test "adds an outE function to the queue" do
      actual_graph = g() |> out_e("foo")
      expected_graph = Queue.in({"outE", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "out/1" do
    test "adds an out function to the queue" do
      actual_graph = g() |> out("foo")
      expected_graph = Queue.in({"out", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "and_/1" do
    test "adds an and function to the queue" do
      actual_graph = g() |> and_()
      expected_graph = Queue.in({"and", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "in_v/1" do
    test "adds an inV function to the queue" do
      actual_graph = g() |> in_v()
      expected_graph = Queue.in({"inV", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "to/1" do
    test "adds a to function to the queue" do
      actual_graph = g() |> to(1)
      expected_graph = Queue.in({"to", [1]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "encode/1" do
    test "compiles queue into a query" do
      graph =
        g() |> v() |> has_label("Intent") |> has("name", "request.group") |> out("sedan")
        |> values("name")

      expected_query =
        "g.V().hasLabel('Intent').has('name', 'request.group').out('sedan').values('name')"

      actual_query = encode(graph)
      assert actual_query == expected_query
    end

    test "compiles query with a vertex id correctly" do
      graph = g() |> v(1)
      expected_query = "g.V(1)"

      actual_query = encode(graph)
      assert actual_query == expected_query
    end

    test "compiles query with a vertex" do
      graph = g() |> v(1) |> add_e("foo") |> to(v(2))
      expected_query = "g.V(1).addE('foo').to(V(2))"

      actual_query = encode(graph)
      assert actual_query == expected_query
    end
  end
end
