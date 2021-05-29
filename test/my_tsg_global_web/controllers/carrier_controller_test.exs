defmodule AppWeb.CarrierControllerTest do
  use AppWeb.ConnCase

  describe "index" do
    test "lists all carriers", %{conn: conn} do
      conn = get(conn, Routes.carrier_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end
end
