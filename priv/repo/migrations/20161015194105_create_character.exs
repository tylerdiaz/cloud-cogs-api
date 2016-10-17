defmodule CloudCogs.Repo.Migrations.CreateCharacter do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add :user_id, references(:users)
      add :credits, :integer
      add :energy, :integer
      add :max_energy, :integer
      add :location_id, references(:locations, type: :uuid)
      add :event_id, references(:events, type: :uuid)

      timestamps()
    end

    create index(:characters, [:location_id])
    create index(:characters, [:event_id])
    create index(:characters, [:user_id])

  end
end
