defmodule MyTsgGlobalWeb.CarrierView do
  use MyTsgGlobalWeb, :view
  alias MyTsgGlobalWeb.CarrierView

  def render("index.json", %{carriers: carriers}) do
    %{data: render_many(carriers, CarrierView, "carrier.json")}
  end

  def render("carrier.json", %{carrier: carrier}) do
    %{
      name: carrier.name
    }
  end
end
