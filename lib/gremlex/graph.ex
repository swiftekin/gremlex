defmodule Gremlex.Graph do
  alias :queue, as: Queue

  def g, do: Queue.new

  def add_v(graph, id) do
    enqueue(graph, "addV", [id])
  end

  def add_edge(graph, edge) do
    enqueue(graph, "addEdge", [edge])
  end

  def property(graph, key, value) do
    enqueue(graph, "property", [key, value])
  end

  def values(graph, key) do
    enqueue(graph, "values", [key])
  end

  def v(graph, id) do
    enqueue(graph, "V", [id])
  end

  defp enqueue(graph, op, args \\ []) do
    Queue.in({op, args}, graph)
  end

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
