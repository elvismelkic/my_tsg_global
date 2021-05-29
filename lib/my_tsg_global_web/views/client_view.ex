defmodule MyTsgGlobalWeb.ClientView do
  use MyTsgGlobalWeb, :view
  alias MyTsgGlobalWeb.ClientView

  def render("index.json", %{clients: clients}) do
    %{data: render_many(clients, ClientView, "client.json")}
  end

  def render("client.json", %{client: client}) do
    %{
      code: client.code
    }
  end
end
