defmodule MyTsgGlobal.Clients do
  @moduledoc """
  The Clients context.
  """

  import Ecto.Query, warn: false
  alias MyTsgGlobal.Repo

  alias MyTsgGlobal.Clients.Client

  @doc """
  Returns the list of clients.
  """
  def list_clients do
    Repo.all(Client)
  end
end
