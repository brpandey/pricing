use Mix.Config


config :pricing, Pricing.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "pricing_test",
  username: "postgres",
  password: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox


config :pricing, Pricing.Scheduler,
  timezone: "America/Chicago",
  jobs: [
    {"* * * * *", {IO, :puts, ["Waka waka waka!"]}} # to test run: iex -S mix test
  ]

