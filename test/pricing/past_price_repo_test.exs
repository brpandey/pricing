defmodule Pricing.PastPriceRepoTest do
  use ExUnit.Case

  alias Pricing.{PastPrice, Product, Repo}

  @old_price 3025
  @updated_price1 2600
  @updated_price2 2450


  @valid_attrs %{product_id: 1, price: 3025, percentage_change: -14.05}
  @invalid_attrs %{product_id: 0, price: 3025, percentage_change: -14.05} # with invalid product id of 0
  @valid_product_attrs %{external_product_id: 12345, price: @old_price, product_name: "Nice Chair"}


  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end


  test "check foreign key constraint for valid product id" do

    # insert a product into db (this will be product id 1)
    {:ok, %Product{id: id}} = Product.create(@valid_product_attrs)


    params = Map.put(@valid_attrs, :product_id, id)

    {:ok, %PastPrice{}} = 
      %PastPrice{} |> PastPrice.changeset(params) |> Repo.insert

  end


  test "check foreign key constraint for invalid product id of 0" do

    {:error, %Ecto.Changeset{errors: e}} = 
      %PastPrice{} 
      |> PastPrice.changeset(@invalid_attrs)
      |> Repo.insert

    assert [product: {"does not exist", []}] = e
  end


  test "fetch the foreign key product record" do
    attrs = %{external_product_id: 12345, price: 3025, product_name: "Nice Chair"}

    # Create product
    {:ok, %Product{} = p1} = Product.create(attrs)

    # Create past price given product
    {:ok, %PastPrice{} = ppr} = PastPrice.create(p1, @updated_price1)

    # Update product
    assert {:ok, %Product{price: @updated_price2} = p2} =
      Product.update(p1, %{price: @updated_price2})

    assert p2 == PastPrice.product(ppr)

  end


end


