defmodule CloudCogs.Location do
  use CloudCogs.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "locations" do
    field :name, :string
    field :image, :string
    belongs_to :parent, CloudCogs.Location

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :image, :parent_id])
    |> validate_required([:name, :image])
  end
end
