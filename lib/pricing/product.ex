defmodule Pricing.Product do
  @moduledoc """
  Mapper module for products table
  Provides validation and casting support as well as 
  convenience db methods to create, update, and query data
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Pricing.{PastPrice, Product, Repo}

  @required_fields ~w(external_product_id price product_name)a
  @optional_fields ~w()

  # Map to products table ensuring we can have many past price records
  schema "products" do
    field(:external_product_id, :integer)
    # in cents
    field(:price, :integer)
    field(:product_name, :string)
    has_many(:past_price_records, PastPrice)

    timestamps()
  end

  @doc """
  Casts and validates requirements, ensures external product id is unique
  """
  def changeset(struct, params \\ :empty) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:external_product_id)
  end

  @doc "Creates product record"
  def create(%{} = params), do: Product.changeset(%Product{}, params) |> Repo.insert()

  @doc "Updates product record"
  def update(%Product{} = p, %{} = params), do: Product.changeset(p, params) |> Repo.update()

  @doc "Retrieves product record by external product id"
  def fetch(:external_product_id, id) when is_integer(id) do
    # from is a macro that builds the Query (queries are composable)
    matching_query = from(p in Product, where: p.external_product_id == ^id)

    # external_product_id is a unique index in the products table so 
    # the response is binary: either we have this product record or not

    Repo.one(matching_query)
  end

  @doc "Retrieves list of past price records for product"
  def price_history(%Product{external_product_id: epid}) do
    matching_query =
      from(
        p in Product,
        where: p.external_product_id == ^epid,
        preload: [:past_price_records]
      )

    result = Repo.one(matching_query)

    case result do
      nil ->
        nil

      %Product{} = product ->
        case product.past_price_records do
          [] -> nil
          records when is_list(records) -> records
        end
    end
  end
end
