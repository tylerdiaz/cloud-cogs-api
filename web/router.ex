defmodule CloudCogs.Router do
  use CloudCogs.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CloudCogs do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]
  end
end
