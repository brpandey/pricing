defmodule Pricing.API.DataTest do
  use ExUnit.Case, async: true # no side effects, so async is fine

  alias Pricing.API.Data


  @valid_attrs %{id: "12345", price: "$30.25", name: "Nice Chair", 
                 category: "home-furnishings", discontinued: false}

  @invalid_attrs %{id: 12345, price: "30.2", name: "Nice Chair", 
                   category: "home-furnishings", discontinued: false}

  @partial_attrs %{id: 12345, name: "Nice Chair", discontinued: false}



  test "changeset with valid attributes" do
    changeset = Data.changeset(%Data{}, @valid_attrs)
    assert changeset.valid?
  end


  test "changeset with invalid attributes" do
    changeset = Data.changeset(%Data{}, @invalid_attrs)
    assert [price: {"has invalid format", [validation: :format]}] = changeset.errors
    refute changeset.valid?
  end


  test "changeset with partial attributes" do
    changeset = Data.changeset(%Data{}, @partial_attrs) # missing price
    assert [price: {"can't be blank", [validation: :required]}, 
            category: {"can't be blank", [validation: :required]}] = changeset.errors
    refute changeset.valid?
  end


end

