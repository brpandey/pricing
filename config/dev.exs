use Mix.Config

config :pricing, Pricing.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "pricing_dev",
  username: "postgres",
  password: "postgres"



config :pricing, Pricing.Scheduler,
  timezone: "America/Chicago",
  jobs: [
    {"@monthly",  {Pricing.Updater, :run, []}} # runs update monthly, same as "0 0 1 * *"
  ]

#   {"* * * * *",  {Pricing.Updater, :run, []}} # to test run iex -S mix


# crontab format

# * * * * * *
# | | | | | | 
# | | | | | +-- Year              (range: 1900-3000)
# | | | | +---- Day of the Week   (range: 1-7, 1 standing for Monday)
# | | | +------ Month of the Year (range: 1-12)
# | | +-------- Day of the Month  (range: 1-31)
# | +---------- Hour              (range: 0-23)
# +------------ Minute            (range: 0-59)




