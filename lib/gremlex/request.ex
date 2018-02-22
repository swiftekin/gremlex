defmodule Gremlex.Request do
  alias Gremlex.Graph
  @derive [Poison.Encoder]
  @op "eval"
  @processor ""
  @enforce_keys [:op, :processor, :requestId, :args]
  defstruct [:op, :processor, :requestId, :args]

  def new(query) do
    payload = Graph.encode(query)
    args = %{gremlin: payload, language: "gremlin-groovy"}
    %Gremlex.Request{requestId: UUID.uuid4(), args: args, op: @op, processor: @processor}
  end
end
