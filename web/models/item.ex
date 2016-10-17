defmodule CloudCogs.Item do
  use CloudCogs.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "items" do
    field :name, :string
    field :image, :string
    field :description, :string
    field :type, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :image, :description, :type])
    |> validate_required([:name, :image, :description, :type])
  end
end
