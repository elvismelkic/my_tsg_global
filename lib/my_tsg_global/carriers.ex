defmodule MyTsgGlobal.Carriers do
  @moduledoc """
  The Carriers context.
  """

  import Ecto.Query, warn: false
  alias MyTsgGlobal.Repo

  alias MyTsgGlobal.Carriers.Carrier

  @doc """
  Returns the list of carriers.
  """
  def list_carriers do
    Repo.all(Carrier)
  end
end
