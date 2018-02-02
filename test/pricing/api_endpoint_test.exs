defmodule Pricing.API.EndpointTest do
  use ExUnit.Case, async: true

  alias Pricing.{API.Endpoint, API.Data}

  @json0a ~s({"wakawaka":"none"})
  @json0b ~s({"productRecords":[]})
  @json0c "{\"productRecords\":[{\"price\":\"$30.25\",\"name\":\"NiceChair\"}"
  @json0d ~s({"productRecords":[{"price":"$30.25","name":"NiceChair"}]})

  @json1 ~s({"productRecords":[{"price":"$30.25","name":"NiceChair","id":123456,"discontinued":false,"category":"home-furnishings"}]})

  @json2a ~s({"productRecords":[{"price":"$30.25","name":"NiceChair","id":123456,"discontinued":false,"category":"home-furnishings"},{"price":"$43.77","name":"Black & White TV","id":234567,"discontinued":true,"category":"electronics"}]})

  # second record price doesn't have two digits precision
  @json2b ~s({"productRecords":[{"price":"$30.25","name":"NiceChair","id":123456,"discontinued":false,"category":"home-furnishings"},{"price":"$43.977","name":"Black & White TV","id":234567,"discontinued":true,"category":"electronics"}]})

  test "json with zero records" do
    assert [] == @json0a |> Endpoint.process_response_body()
  end

  test "json with zero records well formed" do
    assert [] == @json0b |> Endpoint.process_response_body()
  end

  test "invalid json with partial record" do
    assert [] == @json0c |> Endpoint.process_response_body()
  end

  test "valid json with partial record" do
    assert [nil] == @json0d |> Endpoint.process_response_body()
  end

  test "valid json with one record" do
    records = [
      %Data{
        category: "home-furnishings",
        discontinued: false,
        id: 123_456,
        name: "NiceChair",
        price: "$30.25",
        price_cents: 3025
      }
    ]

    assert records == @json1 |> Endpoint.process_response_body()
  end

  test "valid json with two records" do
    records = [
      %Data{
        category: "home-furnishings",
        discontinued: false,
        id: 123_456,
        name: "NiceChair",
        price: "$30.25",
        price_cents: 3025
      },
      %Data{
        category: "electronics",
        discontinued: true,
        id: 234_567,
        name: "Black & White TV",
        price: "$43.77",
        price_cents: 4377
      }
    ]

    assert records == @json2a |> Endpoint.process_response_body()
  end

  test "valid json with two records, one with invalid attrs" do
    records = [
      %Data{
        category: "home-furnishings",
        discontinued: false,
        id: 123_456,
        name: "NiceChair",
        price: "$30.25",
        price_cents: 3025
      },
      nil
    ]

    assert records == @json2b |> Endpoint.process_response_body()
  end
end
