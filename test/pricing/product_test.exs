defmodule Pricing.ProductTest do
  use ExUnit.Case, async: true # no side effects, so async is fine

  alias Pricing.Product


  @valid_attrs %{external_product_id: "12345", price: 3025, product_name: "Nice Chair"}
  @invalid_attrs %{external_product_id: 12345, price: "$30.25", product_name: "Nice Chair"}
  @partial_attrs %{external_product_id: 12345, product_name: "Nice Chair"}


  test "changeset with valid attributes" do
    changeset = Product.changeset(%Product{}, @valid_attrs)
    assert changeset.valid?
  end


  test "changeset with invalid attributes" do
    changeset = Product.changeset(%Product{}, @invalid_attrs) # price is a string when it should be integer
    assert [price: {"is invalid", [type: :integer, validation: :cast]}] = changeset.errors
    refute changeset.valid?
  end


  test "changeset with partial attributes" do
    changeset = Product.changeset(%Product{}, @partial_attrs) # missing price
    assert [price: {"can't be blank", [validation: :required]}] = changeset.errors
    refute changeset.valid?
  end


end

