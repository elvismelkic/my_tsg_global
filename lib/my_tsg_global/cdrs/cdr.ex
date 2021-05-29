defmodule MyTsgGlobal.Cdrs.Cdr do
  use Ecto.Schema
  import Ecto.Changeset
  alias MyTsgGlobal.EctoEnums.ServiceTypeEnum
  alias MyTsgGlobal.Rates.{BuyRate, SellRate}

  @allowed_get_types %{
    client_code: :string,
    year: :integer,
    month: :integer
  }

  @allowed_types %{
    client_code: :string,
    client_name: :string,
    direction: :string,
    carrier: :string,
    destination_number: :string,
    number_of_units: :integer,
    service_type: :string,
    source_number: :string,
    success: :boolean,
    timestamp: :utc_datetime
  }

  schema "cdrs" do
    field(:destination_number, :string)
    field(:number_of_units, :integer)
    field(:service_type, ServiceTypeEnum)
    field(:source_number, :string)
    field(:success, :boolean, default: false)
    field(:timestamp, :utc_datetime)

    belongs_to(:buy_rate, BuyRate)
    belongs_to(:sell_rate, SellRate)

    timestamps()
  end

  @single_attrs ~w/success source_number destination_number service_type number_of_units
                   timestamp buy_rate_id sell_rate_id /a

  @multiple_attrs ~w/success source_number destination_number service_type number_of_units
                     timestamp buy_rate_id sell_rate_id inserted_at updated_at/a

  @validation_get_required_attrs ~w/client_code year month /a

  @validation_required_attrs ~w/client_code direction carrier destination_number
                                number_of_units service_type source_number success /a

  @doc false
  def changeset(cdr, attrs) do
    cdr
    |> cast(attrs, @single_attrs)
    |> validate_required(@single_attrs)
    |> foreign_key_constraint(:buy_rate_id)
    |> foreign_key_constraint(:sell_rate_id)
  end

  @doc false
  def multiple_changeset(cdr, attrs) do
    cdr
    |> cast(attrs, @multiple_attrs)
    |> validate_required(@multiple_attrs)
    |> foreign_key_constraint(:buy_rate_id)
    |> foreign_key_constraint(:sell_rate_id)
  end

  @doc false
  def validate_get(data) do
    {data, @allowed_get_types}
    |> cast(data, @validation_get_required_attrs)
    |> validate_required(@validation_get_required_attrs)
  end

  @doc false
  def validate_post(data) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    data =
      data
      |> Map.update("success", "false", fn value ->
        cond do
          value in ["TRUE", "FALSE", "true", "false"] -> String.downcase(value)
          is_boolean(value) -> value
          true -> nil
        end
      end)
      |> Map.update("direction", "inbound", fn value ->
        if value in ["INBOUND", "OUTBOUND", "inbound", "outbound"],
          do: String.downcase(value),
          else: nil
      end)
      |> Map.update("service_type", "voice", fn value ->
        if value in ["SMS", "MMS", "VOICE", "sms", "mms", "voice"],
          do: String.downcase(value),
          else: nil
      end)
      |> Map.update("timestamp", now, fn datetime ->
        datetime
        |> Timex.parse("{0D}/{0M}/{YYYY} {h24}:{m}:{s}")
        |> case do
          {:ok, datetime} -> Timex.to_datetime(datetime)
          {:error, _} -> nil
        end
      end)

    {data, @allowed_types}
    |> cast(data, @validation_required_attrs ++ [:client_name, :timestamp])
    |> validate_required(@validation_required_attrs)
  end
end
