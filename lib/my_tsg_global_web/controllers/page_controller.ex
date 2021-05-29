defmodule MyTsgGlobalWeb.PageController do
  use MyTsgGlobalWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
