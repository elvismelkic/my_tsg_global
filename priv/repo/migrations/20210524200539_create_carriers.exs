defmodule MyTsgGlobal.Repo.Migrations.CreateCarriers do
  use Ecto.Migration

  def change do
    create table(:carriers) do
      add(:name, :string, null: false)

      timestamps()
    end

    create(unique_index(:carriers, :name))
  end
end
