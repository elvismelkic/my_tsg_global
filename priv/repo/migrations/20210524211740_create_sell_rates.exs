defmodule MyTsgGlobal.Repo.Migrations.CreateSellRates do
  use Ecto.Migration

  def change do
    create table(:sell_rates) do
      add(:direction, :direction, null: false)
      add(:price_start_date, :utc_datetime, null: false)
      add(:sms_rate, :decimal)
      add(:mms_rate, :decimal)
      add(:voice_rate, :decimal)
      add(:client_id, references(:clients, on_delete: :restrict), null: false)

      timestamps()
    end

    create(index(:sell_rates, [:client_id]))

    execute(
      "CREATE INDEX sell_rates_price_start_date_desc_index ON sell_rates (price_start_date DESC NULLS LAST);"
    )
  end
end
