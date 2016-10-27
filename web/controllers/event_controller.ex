# things left:
# - act on an event

require IEx

alias CloudCogs.{Character, DisabledEvent, Event, Repo, ConditionChecker, EventOptions, CharacterLocationNarrative, EffectRunner}

# Code debt relief:
# - Make a struct to replace maps inside the "resource" param for conditionChecker/eventRunner
# - Create event decorator
# - add a plug for user/character loading
# - maybe a debugging tool that shows me all queries run and their time to execute

defmodule CloudCogs.EventController do
  use CloudCogs.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated

  # maybe this should just be called "options" that prioritizes event then location
  def current_event(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    character = Repo.get_by(Character, user_id: user.id)
    |> Repo.preload(event: [:conditions, :children])
    |> Repo.preload(location: [:events])

    # BUG: Need to pass this with a query or where scope maybe
    location_narrative = Repo.all(
      CharacterLocationNarrative
      # character_id: character.id,
      # location_id: character.location.id
    )
    |> Enum.map(fn (e) -> e.narrative_text end)

    options = Enum.concat(character.location.events, character.event.children)
    |> Repo.preload(:conditions)
    |> Enum.filter(fn (event) -> event.cause_type == "actionable" end)
    |> Enum.map(&EventOptions.get_options_for(&1, character))
    |> Enum.reject(fn (v) -> v == nil end)
    |> Enum.map(&EventOptions.format_option(&1))

    conn
    |> render(:event, narrative: location_narrative, options: options)
  end

  def act_on_event(conn, %{"event_id" => event_id}) do
    user = Guardian.Plug.current_resource(conn)
    character = Repo.get_by(Character, user_id: user.id)
    |> Repo.preload(event: [:conditions, :children])
    |> Repo.preload(location: [:events])

    acted_event = Repo.get_by(CloudCogs.Event, id: event_id)
    |> Repo.preload(:effects)
    |> EffectRunner.run_all_event_effects(%{ character: character })

    # might make more sense to have trigger events be location independent and add that as a condition if necessary
    # in which case this query becomes a little trickier
    trigger_events = Enum.concat(character.location.events, character.event.children)
    |> Repo.preload([:effects, :conditions])
    |> Enum.filter(fn (event) -> event.cause_type == "trigger" end)
    |> Enum.filter(&ConditionChecker.event_conditions_met?(&1, %{ character: character }))
    |> Enum.map(&EffectRunner.run_all_event_effects(&1, %{ character: character }))

    current_event(conn, %{})
  end
end

defmodule CloudCogs.EventOptions do
  def get_options_for(event, character) do
    is_actionable = ConditionChecker.event_conditions_met?(
      event,
      %{ character: character }
    )

    cond do
      is_actionable -> event
      event.visible_on_failing_conditions -> %DisabledEvent{ action_label: event.action_label }
      true -> nil
    end
  end

  # Split this out into a "decorator"
  def format_option(event) do
    if Event.disabled?(event) do
      %{label: event.action_label, disabled: true }
    else
      %{label: event.action_label, disabled: false, event_id: event.id}
    end
  end
end

defmodule CloudCogs.ConditionChecker do
  # I'd love to do this I just can't figure out how right now, something like specter for Elixir would be nice
  # @resource_requirement_schema = %{
  # TODO: can I just append a "resource" param instead here? passing character all around feels kinda dirty
  #   hasCredits: %{ character: [:credits] }
  # }

  def event_conditions_met?(event, %{ character: character }) do
    event.conditions
    |> Enum.all?(fn (con) ->
      ConditionChecker.check(con.key, con.payload, character)
    end)
  end

  def check("hasCredits", %{ quantity: minCredits }, %{ credits: credits }) do
    credits >= minCredits
  end
end

defmodule CloudCogs.EffectRunner do
  # TODO: also having string/atom key pattern matching feels dirty. move those to a struct instead.
  def run_all_event_effects(%{ effects: effects }, %{ character: character }) do
    effects
    |> Enum.each(fn (effect) ->
      perform_effect(effect.key, effect.payload, character)
    end)
  end

  def perform_effect("setLocationTo", %{ model_id: model_id }, character) do
    update_character(character, :location_id, model_id)
  end

  def perform_effect("setEventTo", %{ model_id: model_id }, character) do
    update_character(character, :event_id, model_id)
  end

  def perform_effect("narratives", %{ narrative: narratives }, character) do
    narratives |>
      Enum.map(fn (narrative_text) ->
        %CharacterLocationNarrative{
          character_id: character.id,
          location_id: character.location.id,
          narrative_text: narrative_text
    }
    end)
    |> Enum.each(&Repo.insert!(&1))
  end

  def perform_effect("addCredits", %{ quantity: credits }, character) do
    update_character(character, :credits, (character.credits + credits))
  end

  # BUG: this update isn't working
  # might be better to do something like update_where
  defp update_character(character, key, val) do
    Character.changeset(character, %{ key: val })
    |> Repo.update!
  end
end
