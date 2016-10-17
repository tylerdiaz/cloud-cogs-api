defmodule CloudCogs.Repo.Migrations.CreateNpc do
  use Ecto.Migration

  def change do
    create table(:npcs) do
      add :name, :string
      add :image, :string

      timestamps()
    end

  end
end
