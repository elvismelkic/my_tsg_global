defmodule MyTsgGlobal.Repo do
  use Ecto.Repo,
    otp_app: :my_tsg_global,
    adapter: Ecto.Adapters.Postgres
end
