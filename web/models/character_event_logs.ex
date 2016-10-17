defmodule CloudCogs.CharacterEventLogs do
  use CloudCogs.Web, :model

  schema "character_event_logs" do
    belongs_to :character, CloudCogs.Character
    belongs_to :event, CloudCogs.Event, primary_key: :decision_event_id, type: Ecto.UUID
    belongs_to :decision_event, CloudCogs.Event, primary_key: :decision_event_id, type: Ecto.UUID
    field :options, :map

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end
