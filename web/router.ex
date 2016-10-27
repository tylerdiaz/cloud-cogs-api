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
      get "/current_user", CurrentUserController, :show
      get "/current_event", EventController, :current_event
      post "/act_on_event", EventController, :act_on_event
    end
  end
end
