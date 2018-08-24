# Gremlex

An Elixir client for [Gremlin](http://tinkerpop.apache.org/gremlin.html).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `gremlex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gremlex, "~> 0.1.0"}
  ]
end
```

## Examples

The two main modules that you'll want to use are `Gremlex.Graph` and `Gremlex.Client`.

`Gremlex.Graph` is the module that hosts all the functions needed to build a Gremlin query.
The DSL is a simple set of functions that carries over a graph for every step. Once you've
defined your query, you can simply call `Gremlex.Client.query/1` to perform it.

```elixir
iex(1)> alias Gremlex.Graph
Gremlex.Graph
iex(2)> alias Gremlex.Client
Gremlex.Client
iex(3)> Graph.g() |> Graph.v() |> Client.query
{:ok,
 [
   %Gremlex.Vertex{
     id: 1,
     label: "person",
     properties: %{age: [29], name: ["marko"]}
   }
 ]}
```

## Configuration
You can configure Gremlex by adding the following to your `config.exs`:

```elixir
config :gremlex,
  host: "127.0.0.1",
  port: 8182,
  path: "/gremlin",
  pool_size: 10,
  secure: false
```

Gremlex uses [confex](https://github.com/Nebo15/confex), so that you can easily define
your configuration to use environment variables when it comes time to deploying. To do so,
simply have the parameters that need to be dynamically read at run time set to `{:SYSTEM, "ENV_VAR_NAME"}`.

### Parameters
* `host`: Gremlin host to connect to (defaults to "127.0.0.1")
* `port`: Port Gremlin is listening to on host (defaults to 8182)
* `path`: Websocket path to Gremlin (defaults to "/gremlin")
* `pool_size`: The number of connections to keep open in the pool (defaults to 10)
* `secure`: Set to `true` to connect to a server with SSL enabled
