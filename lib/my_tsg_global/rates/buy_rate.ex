defmodule MyTsgGlobal.Rates.BuyRate do
  use Ecto.Schema
  import Ecto.Changeset
  alias MyTsgGlobal.Carriers.Carrier
  alias MyTsgGlobal.Cdrs.Cdr
  alias MyTsgGlobal.EctoEnums.DirectionEnum

  schema "buy_rates" do
    field(:direction, DirectionEnum)
    field(:mms_rate, :decimal)
    field(:rating_start_date, :utc_datetime)
    field(:sms_rate, :decimal)
    field(:voice_rate, :decimal)

    belongs_to(:carrier, Carrier)
    has_many(:cdrs, Cdr)

    timestamps()
  end

  @attrs ~w/direction rating_start_date sms_rate mms_rate voice_rate carrier_id/a
  @multiple_attrs ~w/direction rating_start_date sms_rate mms_rate voice_rate carrier_id inserted_at updated_at/a

  @doc false
  def changeset(buy_rate, attrs) do
    buy_rate
    |> cast(attrs, @attrs)
    |> validate_required([:direction, :rating_start_date, :carrier_id])
    |> foreign_key_constraint(:carrier_id)
  end

  @doc false
  def multiple_changeset(buy_rate, attrs) do
    buy_rate
    |> cast(attrs, @multiple_attrs)
    |> validate_required([:direction, :rating_start_date, :carrier_id, :inserted_at, :updated_at])
    |> foreign_key_constraint(:carrier_id)
  end
end
