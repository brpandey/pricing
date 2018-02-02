defmodule Pricing.UpdaterTest do
  use ExUnit.Case

  alias Pricing.{API.Data, PastPrice, Product, Repo, Updater}

  @ext_prod_id 6663

  @price 3025
  @diff_price 1210

  @data %Data{
    category: "home-furnishings",
    discontinued: false,
    id: @ext_prod_id,
    name: "Nice Chair",
    price: "$30.25",
    price_cents: @price
  }

  @data_discontinued %Data{
    category: "home-furnishings",
    discontinued: true,
    id: @ext_prod_id,
    name: "Nice Chair",
    price: "$30.25",
    price_cents: @price
  }

  # 4 product combinations for the two attributes name and price
  @valid_product_same_name_same_price %{
    external_product_id: @ext_prod_id,
    price: @price,
    product_name: "Nice Chair"
  }
  @valid_product_same_name_diff_price %{
    external_product_id: @ext_prod_id,
    price: @diff_price,
    product_name: "Nice Chair"
  }
  @valid_product_diff_name_same_price %{
    external_product_id: @ext_prod_id,
    price: @price,
    product_name: "Blue Chair"
  }
  @valid_product_diff_name_diff_price %{
    external_product_id: @ext_prod_id,
    price: @diff_price,
    product_name: "High Chair"
  }

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "successful new product record create" do
    # assert that there is not an existing product with a matching external_product_id
    assert nil == Product.fetch(:external_product_id, @ext_prod_id)

    # assert that recent product is not discontinued
    assert false == @data.discontinued

    Updater.process(@data)

    # assert that there is a new product record
    assert Product.fetch(:external_product_id, @ext_prod_id)
  end

  test "unsuccessful new product record create since data record is discontinued" do
    # assert that there is not an existing product with a matching external_product_id
    assert nil == Product.fetch(:external_product_id, @ext_prod_id)

    Updater.process(@data_discontinued)

    # refute that there is a new product record
    refute Product.fetch(:external_product_id, @ext_prod_id)
  end

  test "trigger error message that warns product mismatch given same price" do
    # create a product in db beforehand with differing product name 
    # but same external product id and different price
    {:ok, p} = Product.create(@valid_product_diff_name_same_price)

    Updater.process(@data)

    # assert that the product record hasn't been updated since product names mismatch
    assert ^p = Product.fetch(:external_product_id, @ext_prod_id)
  end

  test "trigger error message that warns product mismatch given different price" do
    # create a product in db beforehand with differing product name 
    # but same external product id and different price
    {:ok, %Product{updated_at: update}} = Product.create(@valid_product_diff_name_diff_price)

    Updater.process(@data)

    # assert that the product record hasn't been updated since product names mismatch
    assert %Product{updated_at: ^update} = Product.fetch(:external_product_id, @ext_prod_id)
  end

  test "unsuccessful create new past price for existing product and product price update given same name and same price" do
    # create the existing product in db beforehand
    {:ok, %Product{updated_at: update}} = Product.create(@valid_product_same_name_same_price)

    Updater.process(@data)

    # assert that the product record hasn't been updated since the price is the same
    assert %Product{updated_at: ^update} = p = Product.fetch(:external_product_id, @ext_prod_id)

    # and assert that a new past price record hasn't been created for the new product
    refute Product.price_history(p)
  end

  test "successful create new past price record for existing product and product price update given same name and different price" do
    # create the existing product in db beforehand
    {:ok, %Product{price: @diff_price}} = Product.create(@valid_product_same_name_diff_price)

    Updater.process(@data)

    # assert that the price has been updated
    assert %Product{price: @price} = p = Product.fetch(:external_product_id, @ext_prod_id)

    # and assert that we have a new past price record with the first price
    assert [%PastPrice{percentage_change: 150.0, price: @diff_price}] = Product.price_history(p)
  end

  test "successful create new past price record for existing product and product price update given same name and different price and discontinued is true" do
    # create the existing product in db beforehand
    {:ok, %Product{price: @diff_price}} = Product.create(@valid_product_same_name_diff_price)

    Updater.process(@data_discontinued)

    # assert that the price has been updated
    assert %Product{price: @price} = p = Product.fetch(:external_product_id, @ext_prod_id)

    # and assert that we have a new past price record with the first price
    assert [%PastPrice{percentage_change: 150.0, price: @diff_price}] = Product.price_history(p)
  end
end
