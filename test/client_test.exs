defmodule Gremlex.ClientTests do
  use Gremlex
  use ExUnit.Case

  describe "query/1" do
    test "that it can return a successful query" do
      {result, response} = g() |> v() |> query
      assert result == :ok
      assert Enum.count(response) > 0
    end

    test "returns an error :script_evaluation_error for a bad request" do
      {result, response, error_message} = g() |> to(1) |> query
      assert result == :error
      assert response == :script_evaluation_error
      assert error_message != ""
    end

    test "allows you to create a new vertex" do
      {result, response} = g() |> add_v("person") |> property("name", "jasper") |> query
      assert Enum.count(response) == 1
      assert result == :ok
      [vertex] = response
      assert vertex.label == "person"
      assert vertex.properties == %{name: ["jasper"]}
    end

    test "returns empty list when there is no content retrieved" do
      {_, response} =
        g() |> v() |> has_label("person") |> has("doesntExist", "doesntExist") |> query

      assert(response == [])
    end
  end
end
