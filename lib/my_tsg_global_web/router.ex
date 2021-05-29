defmodule MyTsgGlobalWeb.Router do
  use MyTsgGlobalWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug(Accent.Plug.Response, json_codec: Jason, default_case: Accent.Case.Camel)
  end

  # Other scopes may use custom stacks.
  scope "/api", MyTsgGlobalWeb do
    pipe_through(:api)

    resources("/cdrs", CdrController, except: [:new, :edit])
    resources("/clients", ClientController, only: [:index])
    resources("/carriers", CarrierController, only: [:index])
  end

  scope "/", MyTsgGlobalWeb do
    pipe_through(:browser)

    resources("/cdrs", CdrController, except: [:new, :edit])
  end
end
