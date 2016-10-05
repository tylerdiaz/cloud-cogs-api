defmodule CloudCogs.Router do
  use CloudCogs.Web, :router

  pipeline :api do
    plug :accepts, ["json"]

    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  scope "/api", CloudCogs do
    pipe_through :api

    scope "/v1" do
      resources "/users", UserController, only: [:create]
      post "/sessions", SessionController, :create
    end
  end
end
