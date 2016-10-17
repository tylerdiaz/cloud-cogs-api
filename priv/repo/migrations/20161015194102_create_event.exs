defmodule CloudCogs.Repo.Migrations.CreateEvent do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :cause_type, :string
      add :name, :string
      add :action_label, :string
      add :visible_on_failing_conditions, :boolean, default: false, null: false
      add :parent_id, :uuid
      add :location_id, references(:locations, type: :uuid)

      timestamps()
    end

  end
end
