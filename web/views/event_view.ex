defmodule CloudCogs.EventView do
  use CloudCogs.Web, :view

  def render("event.json", %{ narrative: narrative, options: options }) do
    %{
      narrative: narrative,
      options: options
    }
  end
end
