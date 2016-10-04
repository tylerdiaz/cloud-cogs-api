defmodule ClougCogs.Router do
  use ClougCogs.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ClougCogs do
    pipe_through :api
    resources "/users", UserController, except: [:new, :edit]
  end
end
