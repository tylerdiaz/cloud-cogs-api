defmodule CloudCogs.Repo.Migrations.CreateCharacterLocationNarrative do
  use Ecto.Migration

  def change do
    create table(:character_location_narratives) do
      add :narrative_text, :string
      add :character_id, references(:characters, on_delete: :nothing)
      add :location_id, references(:locations, on_delete: :nothing, type: :uuid)

      timestamps()
    end
    create index(:character_location_narratives, [:character_id])
    create index(:character_location_narratives, [:location_id])

  end
end
