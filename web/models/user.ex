defmodule ClougCogs.User do
  use ClougCogs.Web, :model

  schema "users" do
    field :email, :string
    field :username, :string
    field :encrypted_password, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :username, :encrypted_password])
    |> validate_required([:email, :username, :encrypted_password])
  end
end
