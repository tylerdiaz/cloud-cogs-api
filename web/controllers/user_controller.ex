defmodule CloudCogs.UserController do
  use CloudCogs.Web, :controller

  alias CloudCogs.User

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        {:ok, jwt, _claims} = Guardian.encode_and_sign(user, :token)

        conn
        |> put_status(:created)
        |> render(CloudCogs.SessionView, :show, jwt: jwt, user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CloudCogs.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
