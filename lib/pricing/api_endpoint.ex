defmodule Pricing.API.Endpoint do
  @moduledoc """
  Provides routine to fetch and process data returned
  from fictitious pricing api
  """

  # injects methods post! and get! etc..
  use HTTPoison.Base
  use Timex

  alias Pricing.API.Data
  require Logger

  # Parameters for fictitious api
  @url Application.get_env(:pricing, :endpoint_url)
  @path Application.get_env(:pricing, :endpoint_path)
  @api_key Application.get_env(:pricing, :api_key)

  # Since the api is fictituous we supply the mock json
  @mock_json ~s({"productRecords": [{"price":"$30.25", "name":"NiceChair", "id":123456, "discontinued":false, "category":"home-furnishings"}, {"price":"$43.77", "name":"Black & White TV", "id":234567, "discontinued":true, "category":"electronics"}]})

  @doc "Issues endpoint data fetch by generating api params and issuing request"
  def fetch() do
    # time now
    end_date = Timex.now("America/Chicago")
    # one month ago
    start_date = Timex.shift(end_date, months: -1)

    api_params = %{
      api_key: @api_key,
      start_date: start_date |> Timex.format!("{YYYY}{0M}{D}"),
      end_date: end_date |> Timex.format!("{YYYY}{0M}{D}")
    }

    mock_get!(@path, [], params: api_params) |> process_response_body
  end

  @doc "Mock version of httpoison base get! function"
  def mock_get!(_, _, _), do: @mock_json

  #############################################################
  # Functions HTTPoison uses for overriding default behavior

  @doc "used by httpoison actions to construct uri"
  def process_url(url) do
    @url <> url
  end

  @doc "prepends json accept header to request headers"
  def process_request_headers(headers) do
    [{"Accept", "application/json"} | headers]
  end

  @doc "handles api endpoint json response body"
  def process_response_body(body) do
    try do
      # decode json
      response = Poison.decode!(body)

      # process productRecords list
      Enum.map(response["productRecords"], fn record ->
        # applies validation and converts string fields to atoms
        # ensure data is validated
        changeset = Data.changeset(%Data{}, record)

        case changeset.valid? do
          # Get Endpoint Data struct with changes applied
          true ->
            %Data{} = Ecto.Changeset.apply_changes(changeset)

          false ->
            nil
        end
      end)
    rescue
      _ ->
        Logger.error("Invalid body #{inspect(body)}")
        []
    end
  end
end
