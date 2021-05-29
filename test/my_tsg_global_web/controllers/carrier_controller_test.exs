defmodule MyTsgGlobalWeb.CarrierControllerTest do
  use MyTsgGlobalWeb.ConnCase

  describe "index" do
    test "lists all carriers", %{conn: conn} do
      conn = get(conn, Routes.carrier_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end
end
