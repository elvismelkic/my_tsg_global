defmodule MyTsgGlobal.Repo.Migrations.CreateCdrs do
  use Ecto.Migration
  import EctoEnum

  defenum(ServiceTypeEnum, :service_type, [:sms, :mms, :voice])

  def change do
    ServiceTypeEnum.create_type()

    create table(:cdrs) do
      add(:success, :boolean, default: false, null: false)
      add(:source_number, :string, null: false)
      add(:destination_number, :string, null: false)
      add(:service_type, ServiceTypeEnum.type(), null: false)
      add(:number_of_units, :integer, null: false)
      add(:timestamp, :utc_datetime, null: false)
      add(:buy_rate_id, references(:buy_rates, on_delete: :restrict), null: false)
      add(:sell_rate_id, references(:sell_rates, on_delete: :restrict), null: false)

      timestamps()
    end

    create(index(:cdrs, [:buy_rate_id]))
    create(index(:cdrs, [:sell_rate_id]))

    execute("CREATE INDEX cdrs_timestamp_desc_index ON cdrs (timestamp DESC NULLS LAST);")
  end
end
