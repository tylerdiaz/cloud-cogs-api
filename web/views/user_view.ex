defmodule ClougCogs.UserView do
  use ClougCogs.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, ClougCogs.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, ClougCogs.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email,
      username: user.username,
      encrypted_password: user.encrypted_password}
  end
end
