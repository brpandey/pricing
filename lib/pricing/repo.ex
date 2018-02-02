defmodule Pricing.Repo do
  # Injects the Ecto Repo functions into the Pricing Repo
  # Enable Ecto functionality for Elixir application pricing
  use Ecto.Repo, otp_app: :pricing
end
