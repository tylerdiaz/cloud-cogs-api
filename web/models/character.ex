defmodule CloudCogs.Character do
  use CloudCogs.Web, :model

  schema "characters" do
    field :credits, :integer
    field :energy, :integer
    field :max_energy, :integer
    belongs_to :location, CloudCogs.Location, type: Ecto.UUID
    belongs_to :event, CloudCogs.Event, type: Ecto.UUID
    belongs_to :user, CloudCogs.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:credits, :energy, :max_energy])
    |> validate_required([:credits, :energy, :max_energy])
  end
end
