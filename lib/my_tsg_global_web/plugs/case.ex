defmodule MyTsgGlobalWeb.Plugs.Case do
  import Plug.Conn

  def init(default \\ nil), do: default

  def call(%Plug.Conn{params: %{"cdrs" => _}} = conn, _default), do: conn

  def call(conn, _default) do
    accent_init_params = Accent.Plug.Request.init()

    Accent.Plug.Request.call(conn, accent_init_params)
  end
end
