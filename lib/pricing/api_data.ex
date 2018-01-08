defmodule Pricing.API.Data do
  @moduledoc """
  Defines data fields returned from Pricing API
  Primarily provides endpoint api data validation with no db persistence
  Converts parameters like string price into price cents cleanly using Ecto paradigm
  """

  use Ecto.Schema
  import Ecto.Changeset


  @cents_conversion 100

  @required_fields ~w(id name price category discontinued)a
  @optional_fields ~w(id_str)

  # We use an embedded schema since we are not persisting this 
  # but merely to validate the API endpoint data in an organized way

  # sets id key to be integer and not autogenerated
  @primary_key {:id, :id, autogenerate: false} 

  
  embedded_schema do
    field :id_str, :string # https://developer.twitter.com/en/docs/basics/twitter-ids
    field :name, :string
    field :price, :string
    field :price_cents, :integer
    field :category, :string
    field :discontinued, :boolean
  end


  @doc "Handles casting and validation for embedded_schema"
  def changeset(struct, params \\ :empty) do

    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
    |> validate_format(:price, ~r/^\$(\d)+\.(\d){2}$/)
    |> put_price_cents()
  end


  # Routine to inject transformed price into changeset
  defp put_price_cents(changeset) do

    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{price: price}} ->
        put_change(changeset, :price_cents, transform_price(price))
      _ ->
        changeset
    end
  end


  # We convert price from String notation to integer cents notation
  defp transform_price(price) when is_binary(price) do

    price 
    |> String.replace("$", "") 
    |> String.to_float 
    |> Kernel.*(@cents_conversion)
    |> Kernel.trunc
  end

end

