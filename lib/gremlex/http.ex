defmodule Gremlex.Http do
  @moduledoc """
  Documentation for Gremlex.
  """

  @host Confex.fetch_env!(:gremlex, :host)

  def build(query) do
    %{gremlin: query}
  end

  def build(query, bindings) do
    %{gremlin: query, bindings: bindings}
  end

  def post(payload) do
    IO.inspect(Poison.encode!(payload), label: "payload")
    HTTPoison.post(@host, Poison.encode!(payload))
  end
end
