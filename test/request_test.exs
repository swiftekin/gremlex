defmodule Gremlex.RequestTests do
  use ExUnit.Case
  alias Gremlex.Request
  import Mock
  import Gremlex.Graph

  describe "new/1" do
    test "construct the proper payload for a gremlin query" do
      with_mock UUID, uuid4: fn -> "uuid" end do
        query = g() |> v()
        payload = "g.V()"
        args = %{gremlin: payload, language: "gremlin-groovy"}
        expected_request = %Request{requestId: "uuid", args: args, op: "eval", processor: ""}
        assert Request.new(query) == expected_request
      end
    end
  end
end
