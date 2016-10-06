defmodule CloudCogs.SessionView do
  use CloudCogs.Web, :view

  def render("show.json", %{jwt: jwt, user: user}) do
    %{
      jwt: jwt,
      user: user
    }
  end

  def render("forbidden.json", err) do
    err
  end

  def render("error.json", _) do
    %{error: "Invalid username or password"}
  end
end
