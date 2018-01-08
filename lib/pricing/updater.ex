defmodule Pricing.Updater do
  @moduledoc """
  Contains business logic to update pricing database.
  Either creates a new product record or udpates an existing 
  product price and creates a past price record or issues error
  """

  alias Pricing.{API.Endpoint, API.Data, PastPrice, Product, Repo}
  require Logger


  @doc "Serves as call point to kick off price tracking updating"
  def run do
    case Endpoint.fetch() do
      [] -> :ok
      list when is_list(list) -> Enum.map(list, &process/1)
    end
  end


  @doc "Serves to process recently obtained data records"
  def process(nil), do: :ok
  def process(%Data{} = recent) do 
    # Issue single db read query
    Product.fetch(:external_product_id, recent.id) |> do_process(recent)
  end


  # Unsuccessful db match
    
  # B) NO MATCHING QUERY, PRODUCT ACTIVE 
  # If there is not an existing product with a matching external_product_id,
  # and the product is not discontinued, create a new product record for it.

  # Don't create new product for discontinued product
  defp do_process(nil, %Data{discontinued: true}), do: :ok 
  defp do_process(nil, %Data{discontinued: false} = recent) do 
    {:ok, p} = Product.create(%{external_product_id: recent.id, 
                                product_name: recent.name, price: recent.price_cents})

    Logger.info("Creating a new product! Product details: #{inspect p}")    
  end


  # A) MATCHING QUERY WITH SAME NAME AND DIFFERING PRICE 
  # If there's an existing product with an external_product_id that matches: 
  # the id of a product in the response and it has the same name and the price differs

  defp do_process(%Product{product_name: pname} = p, %Data{name: rname} = recent)
  when pname == rname do

    if p.price != recent.price_cents do
        
      # Wrap the new past price record insert and product price update 
      # into a single, uniterruptible operation to ensure data consistency 
      
      Repo.transaction fn ->
        # Create a new past price record for the product first.
        # Then update the product's price (Do this even if the item is discontinued)
        {:ok, %PastPrice{}} = PastPrice.create(p, recent.price_cents)
        {:ok, %Product{}} = Product.update(p, %{price: recent.price_cents})
      end
      
    else 
      :ok # Same name, same price -> no op
    end

  end

  
  # C) MATCHING_QUERY WITH PRODUCT NAME MISMATCH 
  # If there is an existing product record with a matching external_product_id, but a different product name
  # log an error message that warns the team that there is a mismatch.
        
  defp do_process(%Product{product_name: pname}, %Data{name: rname})
  when pname != rname do

    # Do not update the price
    msg = "Product Mismatch Error: Found product record with " 
    <> "same external product id but with different product name"
    
    Logger.warn(msg)
  end

end

