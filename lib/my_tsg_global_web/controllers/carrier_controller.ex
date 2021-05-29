defmodule MyTsgGlobalWeb.CarrierController do
  use MyTsgGlobalWeb, :controller

  alias MyTsgGlobal.Carriers

  def index(conn, _params) do
    carriers = Carriers.list_carriers()
    render(conn, "index.json", carriers: carriers)
  end
end
