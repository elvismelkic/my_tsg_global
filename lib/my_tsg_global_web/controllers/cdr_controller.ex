defmodule MyTsgGlobalWeb.CdrController do
  use MyTsgGlobalWeb, :controller

  alias MyTsgGlobal.Cdrs
  alias MyTsgGlobal.Cdrs.Cdr

  action_fallback(MyTsgGlobalWeb.FallbackController)

  def index(conn, %{"client_code" => _} = params) do
    changeset = Cdr.validate_get(params)

    if changeset.valid? do
      cdrs = Cdrs.list_client_data(params)

      render(conn, "sum_data.json", cdrs: cdrs)
    else
      {:error, changeset}
    end
  end

  def index(conn, _params), do: render(conn, "index.html")

  def create(conn, %{"cdrs" => %Plug.Upload{} = cdr_params}) do
    with {:ok, cdrs} <- Cdrs.create_from_csv(cdr_params) do
      conn
      |> put_status(:created)
      |> render("index.json", cdrs: cdrs)
    end
  end

  def create(conn, %{"cdrs" => cdr_params}) do
    changesets = Enum.map(cdr_params, &Cdr.validate_post/1)
    all_valid? = Enum.all?(changesets, & &1.valid?)

    if all_valid? do
      cdr_params = Enum.map(changesets, fn changeset -> changeset.changes end)

      with cdrs <- Cdrs.create_cdrs(cdr_params) do
        conn
        |> put_status(:created)
        |> render("index.json", cdrs: cdrs)
      end
    else
      MyTsgGlobal.Errors.generate_with_message("there are errors in request params")
    end
  end

  def create(conn, %{"cdr" => cdr_params}) do
    changeset = Cdr.validate_post(cdr_params)

    if changeset.valid? do
      with {:ok, %Cdr{} = cdr} <- Cdrs.create_cdr(changeset.changes) do
        conn
        |> put_status(:created)
        |> render("index.json", cdrs: [cdr])
      end
    else
      {:error, changeset}
    end
  end
end
