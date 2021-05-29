defmodule MyTsgGlobalWeb.CdrView do
  use MyTsgGlobalWeb, :view
  alias MyTsgGlobalWeb.CdrView

  def render("index.json", %{cdrs: cdrs}) do
    %{data: render_many(cdrs, CdrView, "cdr.json")}
  end

  def render("show.json", %{cdr: cdr}) do
    %{data: render_one(cdr, CdrView, "cdr.json")}
  end

  def render("sum_data.json", %{cdrs: cdrs}) do
    %{data: render_many(cdrs, CdrView, "cdr_sum.json")}
  end

  def render("cdr.json", %{cdr: cdr}) do
    %{
      id: cdr.id,
      client_code: cdr.sell_rate.client.code,
      source_number: cdr.source_number,
      destination_number: cdr.destination_number,
      direction: cdr.buy_rate.direction,
      service_type: cdr.service_type,
      number_of_units: cdr.number_of_units,
      success: cdr.success,
      carrier: cdr.buy_rate.carrier.name,
      timestamp: cdr.timestamp
    }
  end

  def render("cdr_sum.json", %{cdr: cdr}) do
    %{
      service: cdr.service,
      count: cdr.count,
      total_price: Decimal.round(cdr.total_price, 2)
    }
  end
end
