defmodule CloudCogs.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :image, :string
      add :description, :string
      add :type, :string

      timestamps()
    end

  end
end
