require IEx

defmodule CloudCogs.CurrentUserController do
  use CloudCogs.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated

  def show(conn, _) do
    user = Guardian.Plug.current_resource(conn)

    conn
    |> put_status(:ok)
    |> render(CloudCogs.SessionView, :show, user: user)
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:forbidden)
    |> render(CloudCogs.SessionView, "forbidden.json", error: "Not Authenticated")
  end
end
