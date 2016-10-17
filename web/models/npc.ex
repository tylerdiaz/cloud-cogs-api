defmodule CloudCogs.Npc do
  use CloudCogs.Web, :model

  schema "npcs" do
    field :name, :string
    field :image, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :image])
    |> validate_required([:name, :image])
  end
end
