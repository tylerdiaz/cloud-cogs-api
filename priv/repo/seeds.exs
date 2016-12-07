# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CloudCogs.Repo.insert!(%CloudCogs.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias CloudCogs.{Character, Repo, User, Location, Item, Event, EventEffect, EventCondition, EventNarrative, ConditionPayload}

[
  %{
    username: "admin",
    email: "admin@tylerdiaz.com",
    password: "secret"
  },
]
|> Enum.map(&User.changeset(%User{}, &1))
|> Enum.each(&Repo.insert!(&1))

# Locations
[
  %{
    name: "Sleeping Quarters",
    image: "/images/locations/sleeping_quarters.jpg"
  },
  %{
    name: "Hallway",
    image: "/images/locations/hallway.jpg"
  },
]
|> Enum.map(&Location.changeset(%Location{}, &1))
|> Enum.each(&Repo.insert!(&1))

# Time for events
defmodule GameStateHydrator do
  def hydrate_event(event) do
    if event["conditions"] do
    end

    parent_event = %Event{
      name: Map.get(event, "name", "Untitled event"),
      cause_type: Map.get(event, "cause_type", "actionable"),
      perishable: Map.get(event, "perishable", false),
      action_label: Map.get(event, "action_label", "Go"),
      location_id: Repo.get_by(Location, name: event["location"]).id,
      effects: event_effects(event),
      conditions: event_conditions(event),
    } |> Repo.insert!

    # event["children"]
    # |> Enum.each(&hydrate_event(&1, parent_event))
  end

  def hydrate_event(event, parent) do

  end

  @helper_effect_keys ["setLocationTo", "setEventTo", "narratives"]

  defp event_conditions(event) do
    Map.get(event, "conditions", [])
    |> Enum.map(fn (effect) ->
      %EventCondition{
        key: effect["key"],
        payload: CloudCogs.ConditionPayload.string_keys_to_atoms(effect["payload"])
      }
    end)
  end

  defp event_effects(event) do
    effect_helpers = Map.take(event, @helper_effect_keys)
    |> Map.to_list
    |> Enum.map(&generate_helper_effect(&1))

    Map.get(event, "effects", [])
    |> Enum.map(fn (effect) ->
      %EventEffect{
        key: effect["key"],
        payload: CloudCogs.EffectPayload.string_keys_to_atoms(effect["payload"])
      }
    end)
    |> Enum.concat(effect_helpers)
  end

  defp generate_helper_effect({ eventKey, eventValue }) do
    payload =
      case eventKey do
        "setLocationTo" -> %{ model_id: Repo.get_by(Location, name: eventValue).id }
        "setEventTo" -> %{ model_id: Repo.get_by(Event, name: eventValue).id }
        "narratives" -> %{ narrative: eventValue }
      end

    %EventEffect{
      key: eventKey,
      payload: payload
    }
  end
end

# hydrate game data
Path.wildcard("priv/repo/game_data/*.yaml")
|> Enum.map(&File.read!(&1))
|> Enum.map(&YamlElixir.read_from_string(&1))
|> Enum.map(fn (game_data) ->
  game_data["locations"]
  |> Enum.map(&Location.changeset(%Location{}, &1))
  |> Enum.each(&Repo.insert!(&1))

  game_data["events"]
  |> Enum.each(&GameStateHydrator.hydrate_event(&1))
end)

%Character{
  user_id: Repo.get_by(User, username: "admin").id,
  credits: 120,
  energy: 100,
  max_energy: 100,
  location_id: Repo.get_by(Location, name: "The Bedroom").id,
  event_id: Repo.get_by(Event, name: "The beginning").id
}
|> Repo.insert!

# Repo.get_by(Event, name: "The beginning").id,
#   Repo.get_by(Location, name: "Sleeping Quarters").id,
