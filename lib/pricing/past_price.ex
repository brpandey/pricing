defmodule Pricing.PastPrice do
  @moduledoc """
  Mapper module for past price records table
  Provides validation and casting support as well as 
  convenience db methods to create and query
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Pricing.{PastPrice, Product, Repo}

  @percent_conversion 100
  @precision 2 # 2 precision digits

  @required_atom_fields ~w(product_id price percentage_change)a

  @required_fields ~w(product_id price percentage_change)
  @optional_fields ~w()

  # Map to past price records table ensuring 
  # we are connected back to the products table
  schema "past_price_records" do
    belongs_to :product, Product # foreign key to products
    field :price, :integer
    field :percentage_change, :float

    timestamps()
  end


  @doc """
  Casts and validates requirements, ensures foreign key to product is enforced
  """
  def changeset(struct, params \\ :empty) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(@required_atom_fields)
    |> assoc_constraint(:product)
  end


  @doc "Creates past price record tying it to appropriate product"
  def create(%Product{price: old_price} = p, recent_price)
  when is_integer(recent_price) and is_integer(old_price) do

    # Calculate percent changes from old_price to recent_price
    percent_change = 
      ((recent_price - old_price) / old_price) 
      |> Kernel.*(@percent_conversion)
      |> Float.floor(@precision)

    attrs = %{price: old_price, percentage_change: percent_change}

    Ecto.build_assoc(p, :past_price_records, attrs) |> Repo.insert
  end


  @doc "Returns product to which past price record belongs to"
  def product(%PastPrice{id: id}) do

    result = Repo.one(from ppr in PastPrice, 
                      where: ppr.id == ^id, preload: [:product])
    
    case result do nil -> nil; %PastPrice{} = ppr -> ppr.product end

  end


end

