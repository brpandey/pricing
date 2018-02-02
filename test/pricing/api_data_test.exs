defmodule Pricing.API.DataTest do
  # no side effects, so async is fine
  use ExUnit.Case, async: true

  alias Pricing.API.Data

  @valid_attrs %{
    id: "12345",
    price: "$30.25",
    name: "Nice Chair",
    category: "home-furnishings",
    discontinued: false
  }

  @invalid_attrs %{
    id: 12345,
    price: "30.2",
    name: "Nice Chair",
    category: "home-furnishings",
    discontinued: false
  }

  @partial_attrs %{id: 12345, name: "Nice Chair", discontinued: false}

  test "changeset with valid attributes" do
    changeset = Data.changeset(%Data{}, @valid_attrs)
    assert changeset.valid?
    assert changeset.changes.price == "$30.25"
    assert changeset.changes.price_cents == 3025
  end

  test "changeset with invalid attributes" do
    changeset = Data.changeset(%Data{}, @invalid_attrs)
    assert [price: {"has invalid format", [validation: :format]}] = changeset.errors
    refute changeset.valid?
  end

  test "changeset with partial attributes" do
    # missing price
    changeset = Data.changeset(%Data{}, @partial_attrs)

    assert [
             price: {"can't be blank", [validation: :required]},
             category: {"can't be blank", [validation: :required]}
           ] = changeset.errors

    refute changeset.valid?
  end
end
