defmodule MyTsgGlobalWeb.CdrControllerTest do
  use MyTsgGlobalWeb.ConnCase

  @create_attrs %{
    destination_number: "some destination_number",
    number_of_units: 42,
    service_type: "sms",
    source_number: "some source_number",
    success: "true",
    timestamp: "04/05/2020 13:26:08",
    direction: "outbound"
  }
  @invalid_attrs %{
    destination_number: nil,
    number_of_units: nil,
    service_type: nil,
    source_number: nil,
    success: nil,
    timestamp: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "list cdrs monthly expenses for client", %{conn: conn} do
      TestHelper.create_sell_rate()

      conn =
        get(conn, Routes.cdr_path(conn, :index), %{
          "client_code" => "test code",
          "year" => "2016",
          "month" => "1"
        })

      resp_body = json_response(conn, 200)["data"]

      Enum.each(resp_body, fn service_data ->
        assert service_data["count"] == 0
        assert service_data["totalPrice"] == "0.00"
        assert service_data["service"] in ["sms", "mms", "voice", "total"]
      end)
    end
  end

  describe "create cdr" do
    test "renders cdr when data is valid", %{conn: conn} do
      buy_rate = TestHelper.create_buy_rate()
      sell_rate = TestHelper.create_sell_rate()

      attrs =
        @create_attrs
        |> Map.merge(%{
          client_name: sell_rate.client.name,
          client_code: sell_rate.client.code,
          carrier: buy_rate.carrier.name
        })

      conn = post(conn, Routes.cdr_path(conn, :create), cdr: attrs)

      assert [
               %{
                 "id" => _id,
                 "destinationNumber" => "some destination_number",
                 "numberOfUnits" => 42,
                 "serviceType" => "sms",
                 "sourceNumber" => "some source_number",
                 "success" => true,
                 "direction" => "outbound"
               }
             ] = json_response(conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.cdr_path(conn, :create), cdr: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
