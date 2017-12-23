defmodule Pricing.Repo.Migrations.CreatePastPriceRecord do
  use Ecto.Migration

  def change do
    create table(:past_price_records) do
      add :product_id, references(:products, on_delete: :nothing)
      add :price, :integer
      add :percentage_change, :float

      timestamps()
    end
  end
end

