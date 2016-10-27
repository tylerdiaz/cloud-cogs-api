defmodule CloudCogs.Repo.Migrations.CreateEventEffect do
  use Ecto.Migration

  def change do
    create table(:event_effects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :key, :string
      add :payload, :map
      add :event_id, references(:events, type: :uuid)

      timestamps()
    end

  end
end
