defmodule Pricing.Repo do
  # inject the Ecto Repo functions into the Pricing Repo
  # enable Ecto functionality for Elixir application pricing
  use Ecto.Repo, otp_app: :pricing 
end

