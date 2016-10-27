defmodule CloudCogs.CharacterLocationNarrative do
  use CloudCogs.Web, :model

  schema "character_location_narratives" do
    field :narrative_text, :string
    belongs_to :character, CloudCogs.Character
    belongs_to :location, CloudCogs.Location, type: Ecto.UUID

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:narrative_text])
    |> validate_required([:narrative_text])
  end
end
