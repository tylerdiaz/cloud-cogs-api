defmodule CloudCogs.SessionView do
  use CloudCogs.Web, :view

  def render("show.json", %{jwt: jwt, user: user}) do
    %{
      jwt: jwt,
      user: user
    }
  end
end
