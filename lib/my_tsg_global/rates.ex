defmodule MyTsgGlobal.Rates do
  @moduledoc """
  The Rates context.
  """

  import Ecto.Query, warn: false
  alias MyTsgGlobal.Repo

  alias MyTsgGlobal.Rates.{BuyRate, SellRate}

  @doc """
  Returns the list of buy rates ordered by rating start date in descending order.
  """
  def list_buy_rates do
    from(br in BuyRate,
      order_by: [desc: br.rating_start_date],
      select: br
    )
    |> Repo.all()
    |> Repo.preload(:carrier)
  end

  @doc """
  Returns latest buy rate for specified client and direction.
  """
  def get_last_buy_rate(direction, carrier_name) do
    from(br in BuyRate,
      join: c in MyTsgGlobal.Carriers.Carrier,
      on: br.carrier_id == c.id,
      where: br.direction == ^direction and c.name == ^carrier_name,
      select: br
    )
    |> last(:rating_start_date)
    |> Repo.one()
  end

  @doc """
  Returns the list of sell rates ordered by price start date in descending order.
  """
  def list_sell_rates do
    from(sr in SellRate,
      order_by: [desc: sr.price_start_date],
      select: sr
    )
    |> Repo.all()
    |> Repo.preload(:client)
  end

  @doc """
  Returns latest sell rate for specified client and direction.
  """
  def get_last_sell_rate(direction, client_code) do
    from(sr in SellRate,
      join: c in MyTsgGlobal.Clients.Client,
      on: sr.client_id == c.id,
      where: sr.direction == ^direction and c.code == ^client_code,
      select: sr
    )
    |> last(:price_start_date)
    |> Repo.one()
  end
end
