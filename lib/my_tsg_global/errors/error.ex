defmodule MyTsgGlobal.Errors.Error do
  use Ecto.Schema

  schema "errors" do
    field(:message, :string)
  end
end
