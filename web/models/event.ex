defmodule CloudCogs.DisabledEvent do
  use Ecto.Schema

  embedded_schema do
    field :action_label, :string
  end
end

defmodule CloudCogs.Event do
  alias CloudCogs.{Event, DisabledEvent}
  use CloudCogs.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "events" do
    field :name, :string
    field :action_label, :string
    field :cause_type, :string
    field :visible_on_failing_conditions, :boolean, default: false

    has_many :children, Event, foreign_key: :parent_id
    belongs_to :parent, Event, foreign_key: :parent_id, type: Ecto.UUID
    belongs_to :location, CloudCogs.Location, type: Ecto.UUID

    has_many :conditions, CloudCogs.EventCondition
    has_many :effects, CloudCogs.EventEffect

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :cause_type, :visible_on_failing_conditions])
    |> validate_required([:name, :cause_type ])
  end


  def disabled?(%Event{}), do: false
  def disabled?(%DisabledEvent{}), do: true
end
