defmodule CloudCogs.Repo.Migrations.CreateLocation do
  use Ecto.Migration

  def change do
    create table(:locations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :image, :string
      add :parent_id, :uuid

      timestamps()
    end

  end
end
