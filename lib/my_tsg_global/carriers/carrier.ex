defmodule MyTsgGlobal.Carriers.Carrier do
  use Ecto.Schema
  import Ecto.Changeset
  alias MyTsgGlobal.Rates.BuyRate

  schema "carriers" do
    field(:name, :string)

    has_many(:buy_rates, BuyRate)

    timestamps()
  end

  @doc false
  def changeset(carrier, attrs) do
    carrier
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
