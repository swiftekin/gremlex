defmodule Gremlex.Client do
  use WebSockex
  require Logger
  alias Gremlex.Request
  @mimetype "application/json"

  def start_link([host]) do
    WebSockex.start_link(host, __MODULE__, [])
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected!")
    {:ok, state}
  end

  def query(query) do
    # payload = """
    # {"requestId":"1d6d02bd-8e56-421d-9438-3bd6d0079ff1",
    # "op":"eval",
    # "processor":"",
    # "args":{"gremlin":"g.addV('person').property('country', 'usa')",
    # "language":"gremlin-groovy"}}
    # """
    payload =
      query
      |> Request.new
      |> Poison.encode!
    mime_type_length = << String.length @mimetype >>
    message = mime_type_length <> @mimetype <> payload
    Logger.debug("message: #{message}")
    :poolboy.transaction(:gremlex, fn (worker_pid) ->
      WebSockex.send_frame(worker_pid, {:binary, message})
    end)
  end

  def handle_frame({type, msg}, state) do
    IO.puts "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
    {:ok, state}
  end
end
