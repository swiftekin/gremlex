defmodule Gremlex.Graph do
  @moduledoc """
  Functions for traversing and mutating the Graph.
  Graph operations are stored in a queue which can be created with `g/0`.
  All functions return the queue so that they can be chained together
  similar to how Gremlin queries work.
  Ex:
  The query: `g.V(1).values("name")`

  Would be translated to: `g |> v(1) |> values("name")`
  """
  alias :queue, as: Queue

  @spec t :: {[],[]}

  @doc """
  Start of graph traversal. All graph operations are stored in a queue.
  """
  @spec g :: {Gremlex.Graph.t}
  def g, do: Queue.new

  @doc """
  Appends an addVertex command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec add_v(Gremlex.Graph.t, any()) :: Gremlex.Graph.t
  def add_v(graph, id) do
    enqueue(graph, "addV", [id])
  end

  @doc """
  Appends an addEdge command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec add_edge(Gremlex.Graph.t, any()) :: Gremlex.Graph.t
  def add_edge(graph, edge) do
    enqueue(graph, "addEdge", [edge])
  end

  @doc """
  Appends property command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec property(Gremlex.Graph.t, String.t, any()) :: Gremlex.Graph.t
  def property(graph, key, value) do
    enqueue(graph, "property", [key, value])
  end

  @doc """
  Appends values command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec values(Gremlex.Graph.t, String.t) :: Gremlex.Graph.t
  def values(graph, key) do
    enqueue(graph, "values", [key])
  end

  @doc """
  Appends values the `V` command allowing you to select a vertex.
  Returns a graph to allow chaining.
  """
  @spec values(Gremlex.Graph.t, number()) :: Gremlex.Graph.t
  def v(graph, id) do
    enqueue(graph, "V", [id])
  end

  defp enqueue(graph, op, args \\ []) do
    Queue.in({op, args}, graph)
  end

  @doc """
  Compiles a graph into the Gremlin query.
  """
  @spec encode(Gremlex.Graph.t) :: String.t
  def encode(graph) do
    encode(graph, "g")
  end

  defp encode({[],[]}, acc), do: acc

  defp encode(graph, acc) do
    {{:value, {op, args}}, remainder} = :queue.out(graph)
    args =
      args
      |> Enum.map(fn s -> "'#{s}'" end)
      |> Enum.join(", ")
    encode(remainder, acc <> ".#{op}(#{args})")
  end
end
