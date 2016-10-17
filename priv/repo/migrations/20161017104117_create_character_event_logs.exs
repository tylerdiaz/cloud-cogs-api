defmodule CloudCogs.Repo.Migrations.CreateCharacterEventLogs do
  use Ecto.Migration

  def change do
    create table(:character_event_logs) do
      add :character_id, references(:characters)
      add :event_id, references(:events, type: :uuid)
      add :decision_event_id, references(:events, type: :uuid)
      add :options, :map

      timestamps()
    end
    create index(:character_event_logs, [:character_id])
    create index(:character_event_logs, [:event_id])
    create index(:character_event_logs, [:decision_event_id])
  end
end
