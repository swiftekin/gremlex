use Mix.Config

config :gremlex,
  host: {:system, "GREMLEX_HOST"},
  port: 8182,
  path: "/gremlin",
  pool_size: 10
