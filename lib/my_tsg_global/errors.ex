defmodule MyTsgGlobal.Errors do
  @moduledoc """
  The Errors context.
  """

  import Ecto.Changeset
  alias MyTsgGlobal.Errors.Error

  def generate_with_message(message) do
    {:error, change(%Error{}) |> add_error(:message, message)}
  end
end
