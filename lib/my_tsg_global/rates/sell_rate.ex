defmodule MyTsgGlobal.Rates.SellRate do
  use Ecto.Schema
  import Ecto.Changeset
  alias MyTsgGlobal.Clients.Client
  alias MyTsgGlobal.Cdrs.Cdr
  alias MyTsgGlobal.EctoEnums.DirectionEnum

  schema "sell_rates" do
    field(:direction, DirectionEnum)
    field(:mms_rate, :decimal)
    field(:price_start_date, :utc_datetime)
    field(:sms_rate, :decimal)
    field(:voice_rate, :decimal)

    belongs_to(:client, Client)
    has_many(:cdrs, Cdr)

    timestamps()
  end

  @attrs ~w/direction price_start_date sms_rate mms_rate voice_rate client_id/a
  @multiple_attrs ~w/direction price_start_date sms_rate mms_rate voice_rate client_id inserted_at updated_at/a

  @doc false
  def changeset(sell_rate, attrs) do
    sell_rate
    |> cast(attrs, @attrs)
    |> validate_required([:direction, :price_start_date, :client_id])
    |> foreign_key_constraint(:client_id)
  end

  @doc false
  def multiple_changeset(sell_rate, attrs) do
    sell_rate
    |> cast(attrs, @multiple_attrs)
    |> validate_required([:direction, :price_start_date, :client_id, :inserted_at, :updated_at])
    |> foreign_key_constraint(:client_id)
  end
end
