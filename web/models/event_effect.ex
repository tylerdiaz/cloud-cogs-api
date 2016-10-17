defmodule CloudCogs.EventEffect do
  use CloudCogs.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "eventeffects" do
    field :key, :string
    field :payload, :map
    belongs_to :event, CloudCogs.Event, type: Ecto.UUID

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:key, :payload])
    |> validate_required([:key, :payload])
  end
end
