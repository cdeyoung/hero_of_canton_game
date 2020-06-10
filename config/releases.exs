import Config

config :web, Web.Endpoint,
  server: true,
  http: [port: {:system, "PORT"}],
  url: [host: nil, port: 443]
