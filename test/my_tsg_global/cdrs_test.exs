defmodule MyTsgGlobal.CdrsTest do
  use MyTsgGlobal.DataCase

  alias MyTsgGlobal.Cdrs
  alias MyTsgGlobal.Repo

  describe "cdrs" do
    alias MyTsgGlobal.Clients.Client
    alias MyTsgGlobal.Cdrs.Cdr

    @valid_attrs %{
      client_code: "some code",
      client_name: "client name",
      carrier: "carrier name",
      destination_number: "some destination_number",
      number_of_units: 42,
      service_type: "sms",
      source_number: "some source_number",
      success: "true",
      timestamp: "2010-04-17T14:00:00Z",
      direction: "outbound"
    }

    test "create_cdrs/1 with valid data create cdrs" do
      buy_rate = TestHelper.create_buy_rate()
      sell_rate = TestHelper.create_sell_rate()

      attrs = [
        @valid_attrs
        |> Map.merge(%{
          client_name: sell_rate.client.name,
          client_code: sell_rate.client.code,
          carrier: buy_rate.carrier.name
        })
      ]

      assert [%Cdr{} = cdr] = Cdrs.create_cdrs(attrs)
      assert cdr.destination_number == "some destination_number"
      assert cdr.number_of_units == 42
      assert cdr.service_type == :sms
      assert cdr.source_number == "some source_number"
      assert cdr.success == true
      assert cdr.timestamp == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_cdr/1 with valid data creates a cdr" do
      buy_rate = TestHelper.create_buy_rate()
      sell_rate = TestHelper.create_sell_rate()

      attrs =
        @valid_attrs
        |> Map.merge(%{
          client_name: sell_rate.client.name,
          client_code: sell_rate.client.code,
          carrier: buy_rate.carrier.name
        })

      assert {:ok, %Cdr{} = cdr} = Cdrs.create_cdr(attrs)
      assert cdr.destination_number == "some destination_number"
      assert cdr.number_of_units == 42
      assert cdr.service_type == :sms
      assert cdr.source_number == "some source_number"
      assert cdr.success == true
      assert cdr.timestamp == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "list_client_data/1 returns services sum for chosen month" do
      TestHelper.generate_cdr_get_endpoint_data()

      client = Client |> Repo.all() |> hd()

      params = %{"client_code" => client.code, "year" => "2016", "month" => "1"}

      assert [mms_data, sms_data, total_data, voice_data] =
               params |> Cdrs.list_client_data() |> Enum.sort_by(& &1.service)

      without_total = [mms_data, sms_data, voice_data]

      count_sum =
        Enum.reduce(without_total, 0, fn service_data, total_count ->
          total_count + service_data.count
        end)

      total_price_sum =
        Enum.reduce(without_total, Decimal.new(0), fn service_data, total_count ->
          Decimal.add(total_count, service_data.total_price)
        end)

      assert %{count: 1, service: :mms, total_price: Decimal.new("0.11")} == mms_data
      assert %{count: 2, service: :sms, total_price: Decimal.new("0.022")} == sms_data
      assert %{count: 100, service: :voice, total_price: Decimal.new("110.0")} == voice_data
      assert total_data.service == :total
      assert total_data.count == count_sum
      assert total_data.total_price == total_price_sum
    end
  end
end
