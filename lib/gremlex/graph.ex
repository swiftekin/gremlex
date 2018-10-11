defmodule Gremlex.Graph do
  @moduledoc """
  Functions for traversing and mutating the Graph.

  Graph operations are stored in a queue which can be created with `g/0`.
  Mosts functions return the queue so that they can be chained together
  similar to how Gremlin queries work.

  Example:
  ```
  g.V(1).values("name")
  ```
  Would translate to
  ```
  g |> v(1) |> values("name")
  ```

  Note: This module doesn't actually execute any queries, it just allows you to build one.
  For query execution see `Gremlex.Client.query/1`
  """
  alias :queue, as: Queue

  @type t :: {[], []}
  @default_namespace_property "namespace"
  @default_namespace "gremlex"

  @doc """
  Start of graph traversal. All graph operations are stored in a queue.
  """
  @spec g :: Gremlex.Graph.t()
  def g, do: Queue.new()

  @doc """
  Appends an addV command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec add_v(Gremlex.Graph.t(), any()) :: Gremlex.Graph.t()
  def add_v(graph, id) do
    enqueue(graph, "addV", [id])
  end

  @doc """
  Appends an addE command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec add_e(Gremlex.Graph.t(), any()) :: Gremlex.Graph.t()
  def add_e(graph, edge) do
    enqueue(graph, "addE", [edge])
  end

  @spec has_label(Gremlex.Graph.t(), any()) :: Gremlex.Graph.t()
  def has_label(graph, label) do
    enqueue(graph, "hasLabel", [label])
  end

  @spec has(Gremlex.Graph.t(), any(), any()) :: Gremlex.Graph.t()
  def has(graph, key, value) do
    enqueue(graph, "has", [key, value])
  end

  @doc """
  Appends property command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec property(Gremlex.Graph.t(), String.t(), any()) :: Gremlex.Graph.t()
  def property(graph, key, value) do
    enqueue(graph, "property", [key, value])
  end

  @spec property(Gremlex.Graph.t(), atom(), String.t(), any()) :: Gremlex.Graph.t()
  def property(graph, :single, key, value) do
    enqueue(graph, "property", [:single, key, value])
  end

  @spec property(Gremlex.Graph.t(), atom(), String.t(), any()) :: Gremlex.Graph.t()
  def property(graph, :list, key, value) do
    enqueue(graph, "property", [:list, key, value])
  end

  @spec property(Gremlex.Graph.t(), atom(), String.t(), any()) :: Gremlex.Graph.t()
  def property(graph, :set, key, value) do
    enqueue(graph, "property", [:set, key, value])
  end

    @doc """
  Appends properties command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec properties(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def properties(graph, key) do
    enqueue(graph, "properties", [key])
  end

  @spec properties(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def properties(graph) do
    enqueue(graph, "properties", [])
  end

      @doc """
  Appends valueMap command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec value_map(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def value_map(graph) do
    enqueue(graph, "valueMap", [])
  end

  @spec value_map(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def value_map(graph, value) when is_binary(value) do
    enqueue(graph, "valueMap", [value])
  end

  @spec value_map(Gremlex.Graph.t(), list(String.t())) :: Gremlex.Graph.t()
  def value_map(graph, values) when is_list(values) do
    enqueue(graph, "valueMap", values)
  end

  @doc """
  Appends values command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec values(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def values(graph, key) do
    enqueue(graph, "values", [key])
  end

  @doc """
  Appends values the `V` command allowing you to select a vertex.
  Returns a graph to allow chaining.
  """
  @spec v(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def v({h, t} = graph) when is_list(h) and is_list(t) do
    enqueue(graph, "V", [])
  end

  @spec v(number()) :: Gremlex.Vertex.t()
  def v(id) do
    %Gremlex.Vertex{id: id, label: ""}
  end

  @spec v(Gremlex.Graph.t(), Gremlex.Vertex.t()) :: Gremlex.Graph.t()
  def v(graph, %Gremlex.Vertex{id: id}) do
    enqueue(graph, "V", [id])
  end

  @doc """
  Appends values the `V` command allowing you to select a vertex.
  Returns a graph to allow chaining.
  """
  @spec v(Gremlex.Graph.t(), number()) :: Gremlex.Graph.t()
  def v(graph, id) when is_number(id) or is_binary(id) do
    enqueue(graph, "V", [id])
  end

  @spec in_e(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def in_e(graph, edge) do
    enqueue(graph, "inE", [edge])
  end

  @spec in_e(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def in_e(graph) do
    enqueue(graph, "inE", [])
  end

  @spec out_e(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def out_e(graph, edge) do
    enqueue(graph, "outE", [edge])
  end

  @spec out_e(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def out_e(graph) do
    enqueue(graph, "outE", [])
  end

  @spec out(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def out(graph, edge) do
    enqueue(graph, "out", [edge])
  end

  @spec out(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def out(graph) do
    enqueue(graph, "out", [])
  end

  @spec in_(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def in_(graph, edge) do
    enqueue(graph, "in", [edge])
  end

  @spec in_(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def in_(graph) do
    enqueue(graph, "in", [])
  end

  @spec or_(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def or_(graph) do
    enqueue(graph, "or", [])
  end

  @spec and_(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def and_(graph) do
    enqueue(graph, "and", [])
  end

  @spec in_v(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def in_v(graph) do
    enqueue(graph, "inV", [])
  end

  @spec out_v(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def out_v(graph) do
    enqueue(graph, "outV", [])
  end

  @spec both(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def both(graph) do
    enqueue(graph, "both", [])
  end

  @spec both_e(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def both_e(graph) do
    enqueue(graph, "bothE", [])
  end

  @spec both_v(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def both_v(graph) do
    enqueue(graph, "bothV", [])
  end

  @spec dedup(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def dedup(graph) do
    enqueue(graph, "dedup", [])
  end

  @spec to(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def to(graph, target) do
    enqueue(graph, "to", [target])
  end

  @spec has_next(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def has_next(graph) do
    enqueue(graph, "hasNext", [])
  end

  @spec next(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def next(graph) do
    enqueue(graph, "next", [])
  end

  @spec next(Gremlex.Graph.t(), number()) :: Gremlex.Graph.t()
  def next(graph, numberOfResults) do
    enqueue(graph, "next", [numberOfResults])
  end

  @spec try_next(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def try_next(graph) do
    enqueue(graph, "tryNext", [])
  end

  @spec to_list(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def to_list(graph) do
    enqueue(graph, "toList", [])
  end

  @spec to_set(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def to_set(graph) do
    enqueue(graph, "toSet", [])
  end

  @spec to_bulk_set(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def to_bulk_set(graph) do
    enqueue(graph, "toBulkSet", [])
  end

  @spec drop(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def drop(graph) do
    enqueue(graph, "drop", [])
  end

  @spec iterate(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def iterate(graph) do
    enqueue(graph, "iterate", [])
  end

  @spec identity(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def identity(graph) do
    enqueue(graph, "identity", [])
  end

  defp enqueue(graph, op, args) do
    Queue.in({op, args}, graph)
  end

  @doc """
  Appends values the `E` command allowing you to select an edge.
  Returns a graph to allow chaining.
  """
  @spec e(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def e(graph) do
    enqueue(graph, "E", [])
  end

  @spec e(Gremlex.Graph.t(), Gremlex.Edge.t()) :: Gremlex.Graph.t()
  def e(graph, %Gremlex.Edge{id: id}) do
    enqueue(graph, "E", [id])
  end

  @spec e(Gremlex.Graph.t(), number | String.t()) :: Gremlex.Graph.t()
  def e(graph, id) when is_number(id) or is_binary(id) do
    enqueue(graph, "E", [id])
  end

  @doc """
  Adds a namespace as property
  """
  @spec add_namespace(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def add_namespace(graph) do
    add_namespace(graph, namespace())
  end

  @spec add_namespace(Gremlex.Graph.t(), any()) :: Gremlex.Graph.t()
  def add_namespace(graph, ns) do
    graph |> property(namespace_property(), ns)
  end

  @spec has_namespace(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def has_namespace(graph) do
    has_namespace(graph, namespace())
  end

  @spec has_namespace(Gremlex.Graph.t(), any()) :: Gremlex.Graph.t()
  def has_namespace(graph, ns) do
    graph |> has(namespace_property(), ns)
  end


  @doc """
  Compiles a graph into the Gremlin query.
  """
  @spec encode(Gremlex.Graph.t()) :: String.t()
  def encode(graph) do
    encode(graph, "g")
  end

  defp encode({[], []}, acc), do: acc

  defp encode(graph, acc) do
    {{:value, {op, args}}, remainder} = :queue.out(graph)

    args =
      args
      |> Enum.map(fn
        nil ->
          "none"

        %Gremlex.Vertex{id: id} when is_number(id) ->
          "V(#{id})"

        %Gremlex.Vertex{id: id} when is_binary(id) ->
          "V('#{id}')"

        arg when is_number(arg) or is_atom(arg) ->
          "#{arg}"

        str ->
          "'#{escape(str)}'"
      end)
      |> Enum.join(", ")

    encode(remainder, acc <> ".#{op}(#{args})")
  end

  @spec escape(String.t()) :: String.t()
  defp escape(str) do
    # We escape single quote if it is not already escaped by an odd number of backslashes
    String.replace(str, ~r/((\A|[^\\])(\\\\)*)'/, "\\1\\'")
  end

  defp namespace_property do
    Confex.get_env(:gremlex, :namespace_property, @default_namespace_property)
  end

  defp namespace do
    Confex.get_env(:gremlex, :namespace_name, @default_namespace)
  end
end
