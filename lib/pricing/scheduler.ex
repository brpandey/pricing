defmodule Pricing.Scheduler do
  # Injects the Quantum scheduler functions into the Pricing Repo
  # Enable Quantum cron like functionality for Elixir application pricing
  use Quantum.Scheduler, otp_app: :pricing
end

