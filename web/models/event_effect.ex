defmodule CloudCogs.EventEffect do
  use CloudCogs.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "event_effects" do
    field :key, :string
    embeds_one :payload, CloudCogs.EffectPayload
    belongs_to :event, CloudCogs.Event, type: Ecto.UUID

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:key])
    |> cast_embed(:payload, required: true)
    |> validate_required([:key])
  end
end

defmodule CloudCogs.EffectPayload do
  use Ecto.Schema

  # how can I make these optional on db population? all rows now have like :quantity NULL
  embedded_schema do
    field :quantity, :integer
    field :narrative, {:array, :string}
    field :model_id, Ecto.UUID
  end

  def import_from_map(payload_map) do
    %CloudCogs.EffectPayload{}
    |> Map.merge(string_keys_to_atoms(payload_map))
  end

  def string_keys_to_atoms(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end
end
