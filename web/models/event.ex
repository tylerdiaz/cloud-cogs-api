defmodule CloudCogs.Event do
  alias CloudCogs.Event
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

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :cause_type, :visible_on_failing_conditions])
    |> validate_required([:name, :cause_type ])
  end

  @doc """
    Recursively loads parents into the given struct until it hits nil
  """
  def load_parents(parent) do
    load_parents(parent, 10)
  end

  def load_parents(_, limit) when limit < 0, do: raise "Recursion limit reached"

  def load_parents(%Event{parent: nil} = parent, _), do: parent

  def load_parents(%Event{parent: %Ecto.Association.NotLoaded{}} = parent, limit) do
    parent = parent |> Repo.preload(:parent)
    Map.update!(parent, :parent, &Event.load_parents(&1, limit - 1))
  end

  def load_parents(nil, _), do: nil

  @doc """
    Recursively loads children into the given struct until it hits []
  """
  def load_children(model), do: load_children(model, 10)

  def load_children(_, limit) when limit < 0, do: raise "Recursion limit reached"

  def load_children(%Event{children: %Ecto.Association.NotLoaded{}} = model, limit) do
    model = model |> Repo.preload(:children) # maybe include a custom query here to preserve some order
    Map.update!(model, :children, fn(list) ->
      Enum.map(list, &Event.load_children(&1, limit - 1))
    end)
  end
end
