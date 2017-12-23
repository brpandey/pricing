defmodule Pricing.Repo.Migrations.CreateProduct do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :external_product_id, :integer
      add :price, :integer # in cents
      add :product_name, :string

      timestamps()
    end

    # Create database constraint 
    # Ensure we don't have multiple product records with the same external_product_id
    # a single external_product_id corresponds to a single product

    create unique_index(:products, [:external_product_id])
  end
end

