defmodule CloudCogs.SessionController do
  use CloudCogs.Web, :controller
  alias CloudCogs.User

  def create(conn, %{"session" => session_params}) do
    user = Repo.get_by(User, username: session_params["username"])

    case User.verify_password(user, session_params["password"]) do
      true ->
        {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user, :token)

        conn
        |> put_status(:created)
        |> render(:show, jwt: jwt, user: user)
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error)
    end
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:forbidden)
    |> render(:forbidden, error: "Not Authenticated")
  end
end
