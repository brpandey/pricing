defmodule Pricing.ProductRepoTest do
  use ExUnit.Case
  alias Pricing.{PastPrice, Product, Repo}

  @old_price 3025
  @updated_price1 2600
  @updated_price2 2450

  @valid_external_product_id 12345
  @invalid_external_product_id 99991

  @valid_attrs %{external_product_id: 12345, price: @old_price, product_name: "Nice Chair"}
  @invalid_attrs %{external_product_id: [12345], price: @old_price, product_name: "Nice Chair"}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "basic create" do
    {:ok, %Product{price: @old_price, product_name: "Nice Chair", external_product_id: 12345}} =
      Product.create(@valid_attrs)
  end

  test "erroneous create" do
    {:error, %Ecto.Changeset{errors: e}} = Product.create(@invalid_attrs)
    assert [external_product_id: {"is invalid", [type: :integer, validation: :cast]}] = e
  end

  test "valid update" do
    {:ok, %Product{price: @old_price, product_name: "Nice Chair", external_product_id: 12345} = p} =
      Product.create(@valid_attrs)

    assert {:ok,
            %Product{
              price: @updated_price1,
              product_name: "Nice Chair",
              external_product_id: 12345
            }} = Product.update(p, %{price: @updated_price1})
  end

  test "invalid update" do
    {:ok, %Product{price: @old_price, product_name: "Nice Chair", external_product_id: 12345} = p} =
      Product.create(@valid_attrs)

    assert {:error, %Ecto.Changeset{}} = Product.update(p, %{product_name: 323})
  end

  test "successful retrieve product record by external product id" do
    {:ok, %Product{external_product_id: @valid_external_product_id}} =
      Product.create(@valid_attrs)

    %Product{external_product_id: @valid_external_product_id} =
      Product.fetch(:external_product_id, @valid_external_product_id)
  end

  test "unsuccessful retrieve product record by external product id" do
    # we haven't inserted a producted record with the value contained
    # in the invalid_external_product_id

    assert nil == Product.fetch(:external_product_id, @invalid_external_product_id)
  end

  test "trigger constraint error in the form of changeset error by inserting same product twice" do
    {:ok, %Product{price: @old_price, product_name: "Nice Chair", external_product_id: 12345}} =
      Product.create(@valid_attrs)

    {:error, %Ecto.Changeset{errors: e}} = Product.create(@valid_attrs)

    assert [external_product_id: {"has already been taken", []}] = e
  end

  test "ensure the one-to-many association to past price records works with multiple records" do
    {:ok, %Product{} = p} = Product.create(@valid_attrs)

    {:ok, %PastPrice{} = ppr1} = PastPrice.create(p, @updated_price1)
    {:ok, %PastPrice{} = ppr2} = PastPrice.create(p, @updated_price2)

    assert [ppr1, ppr2] == Product.price_history(p)
  end

  test "ensure the one-to-many association to past price records works with zero past records" do
    {:ok, %Product{} = p} = Product.create(@valid_attrs)

    assert nil == Product.price_history(p)
  end
end
