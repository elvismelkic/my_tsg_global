defmodule MyTsgGlobal.Clients.Client do
  use Ecto.Schema
  import Ecto.Changeset
  alias MyTsgGlobal.Rates.SellRate

  schema "clients" do
    field(:code, :string)
    field(:name, :string)

    has_many(:sell_rates, SellRate)

    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [:name, :code])
    |> validate_required([:name, :code])
    |> unique_constraint(:code)
  end
end
