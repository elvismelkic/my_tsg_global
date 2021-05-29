defmodule MyTsgGlobal.TestHelper do
  @moduledoc """
  Test Helpers for creating database records
  """

  alias MyTsgGlobal.{Cdrs, Repo}
  alias MyTsgGlobal.Cdrs.Cdr
  alias MyTsgGlobal.Carriers.Carrier
  alias MyTsgGlobal.Clients.Client
  alias MyTsgGlobal.Rates.{BuyRate, SellRate}

  @carrier_attrs %{name: "test carrier"}
  @client_attrs %{name: "test client", code: "test code"}
  @buy_rate_attrs %{
    direction: :outbound,
    mms_rate: "0.01",
    rating_start_date: "2010-04-17T14:00:00Z",
    sms_rate: "0.001",
    voice_rate: "0.1"
  }
  @sell_rate_attrs %{
    direction: :outbound,
    mms_rate: "0.1",
    price_start_date: "2010-04-17T14:00:00Z",
    sms_rate: "0.01",
    voice_rate: "1"
  }
  @cdr_attrs %{
    destination_number: "some destination_number",
    number_of_units: 42,
    service_type: "sms",
    source_number: "some source_number",
    success: "true",
    timestamp: ~U[2020-05-04 13:26:08.003Z],
    direction: "outbound"
  }

  def create_carrier, do: %Carrier{} |> Carrier.changeset(@carrier_attrs) |> Repo.insert!()

  def create_client, do: %Client{} |> Client.changeset(@client_attrs) |> Repo.insert!()

  def create_buy_rate do
    carrier = create_carrier()
    buy_rate_attrs = Map.put(@buy_rate_attrs, :carrier_id, carrier.id)
    buy_rate = %BuyRate{} |> BuyRate.changeset(buy_rate_attrs) |> Repo.insert!()

    buy_rate |> Repo.preload(:carrier)
  end

  def create_sell_rate do
    client = create_client()
    sell_rate_attrs = Map.put(@sell_rate_attrs, :client_id, client.id)
    sell_rate = %SellRate{} |> SellRate.changeset(sell_rate_attrs) |> Repo.insert!()

    sell_rate |> Repo.preload(:client)
  end

  def create_cdr do
    buy_rate = create_buy_rate()
    sell_rate = create_sell_rate()

    {:ok, cdr} =
      @cdr_attrs
      |> Map.merge(%{
        client_name: sell_rate.client.name,
        client_code: sell_rate.client.code,
        carrier: buy_rate.carrier.name
      })
      |> Cdrs.create_cdr()

    cdr
  end

  def generate_cdr_get_endpoint_data do
    buy_rate = create_buy_rate()
    sell_rate = create_sell_rate()
    carrier_name = buy_rate.carrier.name
    %Client{name: client_name, code: client_code} = sell_rate.client
    direction = buy_rate.direction |> Atom.to_string() |> String.upcase()

    cdrs = [
      %{
        "carrier" => carrier_name,
        "client_code" => client_code,
        "client_name" => client_name,
        "destination_number" => "16194401000",
        "direction" => direction,
        "number_of_units" => "90",
        "service_type" => "VOICE",
        "source_number" => "14239990570",
        "success" => "TRUE",
        "timestamp" => "01/01/2016 00:07:36"
      },
      %{
        "carrier" => carrier_name,
        "client_code" => client_code,
        "client_name" => client_name,
        "destination_number" => "16194401000",
        "direction" => direction,
        "number_of_units" => "10",
        "service_type" => "VOICE",
        "source_number" => "14239990570",
        "success" => "TRUE",
        "timestamp" => "01/01/2016 01:07:36"
      },
      %{
        "carrier" => carrier_name,
        "client_code" => client_code,
        "client_name" => client_name,
        "destination_number" => "16194401000",
        "direction" => direction,
        "number_of_units" => "1",
        "service_type" => "MMS",
        "source_number" => "14239990570",
        "success" => "TRUE",
        "timestamp" => "01/02/2016 00:07:36"
      },
      %{
        "carrier" => carrier_name,
        "client_code" => client_code,
        "client_name" => client_name,
        "destination_number" => "16194401000",
        "direction" => direction,
        "number_of_units" => "1",
        "service_type" => "MMS",
        "source_number" => "14239990570",
        "success" => "TRUE",
        "timestamp" => "01/01/2016 01:07:36"
      },
      %{
        "carrier" => carrier_name,
        "client_code" => client_code,
        "client_name" => client_name,
        "destination_number" => "16194401000",
        "direction" => direction,
        "number_of_units" => "1",
        "service_type" => "SMS",
        "source_number" => "14239990570",
        "success" => "TRUE",
        "timestamp" => "01/01/2016 00:07:36"
      },
      %{
        "carrier" => carrier_name,
        "client_code" => client_code,
        "client_name" => client_name,
        "destination_number" => "16194401000",
        "direction" => direction,
        "number_of_units" => "1",
        "service_type" => "SMS",
        "source_number" => "14239990570",
        "success" => "TRUE",
        "timestamp" => "01/01/2016 01:07:36"
      }
    ]

    cdrs
    |> Enum.map(&Cdr.validate_post/1)
    |> Enum.map(fn changeset -> changeset.changes end)
    |> Cdrs.create_cdrs()
  end
end
