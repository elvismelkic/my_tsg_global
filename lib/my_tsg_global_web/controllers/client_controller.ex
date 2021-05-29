defmodule MyTsgGlobalWeb.ClientController do
  use MyTsgGlobalWeb, :controller

  alias MyTsgGlobal.Clients

  def index(conn, _params) do
    clients = Clients.list_clients()
    render(conn, "index.json", clients: clients)
  end
end
