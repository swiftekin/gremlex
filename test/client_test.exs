defmodule Gremlex.ClientTests do
  use Gremlex
  use ExUnit.Case

  describe "query/1" do
    test "that it can return a successful query" do
      {result, response} = g() |> v() |> query
      assert result == :ok
      assert Enum.count(response) == 6
    end

    test "returns an error :script_evaluation_error for a bad request" do
      {result, response, error_message} = g() |> to(1) |> query
      assert result == :error
      assert response == :script_evaluation_error
      assert error_message != ""
    end
  end
end
