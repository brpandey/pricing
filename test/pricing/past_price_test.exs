defmodule Pricing.PastPriceTest do
  use ExUnit.Case, async: true # no side effects, so async is fine

  alias Pricing.PastPrice

  @valid_attrs1 %{product_id: 23, price: 3025, percentage_change: -14.05} # with new price of 2600
  @invalid_attrs %{product_id: 23, price: "$34.00", percentage_change: 23}
  @partial_attrs %{price: 2600} # with new price of 2450


  test "changeset with valid attributes" do
    changeset = PastPrice.changeset(%PastPrice{}, @valid_attrs1)
    assert changeset.valid?
  end


  test "changeset with invalid attributes" do
    changeset = PastPrice.changeset(%PastPrice{}, @invalid_attrs)
    assert [price: {"is invalid", [type: :integer, validation: :cast]}] = changeset.errors

    refute changeset.valid?
  end


  test "changeset with partial attributes" do
    changeset = PastPrice.changeset(%PastPrice{}, @partial_attrs)
    assert [product_id: {"can't be blank", [validation: :required]},
             percentage_change: {"can't be blank", [validation: :required]}] = changeset.errors

    refute changeset.valid?
  end


end


