defmodule MyTsgGlobal.Repo.Migrations.CreateBuyRates do
  use Ecto.Migration
  import EctoEnum

  defenum(DirectionEnum, :direction, [:inbound, :outbound])

  def change do
    DirectionEnum.create_type()

    create table(:buy_rates) do
      add(:direction, DirectionEnum.type(), null: false)
      add(:rating_start_date, :utc_datetime, null: false)
      add(:sms_rate, :decimal)
      add(:mms_rate, :decimal)
      add(:voice_rate, :decimal)
      add(:carrier_id, references(:carriers, on_delete: :restrict), null: false)

      timestamps()
    end

    create(index(:buy_rates, [:carrier_id]))

    execute(
      "CREATE INDEX buy_rates_rating_start_date_desc_index ON buy_rates (rating_start_date DESC NULLS LAST);"
    )
  end
end
