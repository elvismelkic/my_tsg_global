defmodule MyTsgGlobal.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add(:name, :string, null: false)
      add(:code, :string, null: false)

      timestamps()
    end

    create(unique_index(:clients, :code))
  end
end
