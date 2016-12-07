alias CloudCogs.{Character, DisabledEvent, Event, Repo, ConditionChecker, EventOptions, CharacterLocationNarrative, CharacterEventLogs, EffectRunner}

# Code debt relief:
# - add a plug for user/character loading
# - maybe a debugging tool that shows me all queries run and their time to execute
# - modifying event_id/location_id directly. should I be doing this?
# - better error handling when you're performing an event you shouldn't be

defmodule CloudCogs.EventController do
  use CloudCogs.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated

  # maybe this should just be called "options" that prioritizes event then location
  def current_event(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    character = Repo.get_by(Character, user_id: user.id)
    |> Repo.preload(event: [:conditions, :children])
    |> Repo.preload(location: [:events])

    location_narrative = CharacterLocationNarrative
    |> where(character_id: ^character.id, location_id: ^character.location.id)
    |> Repo.all
    |> Enum.map(fn (e) -> e.narrative_text end)

    options = event_options(character)
    |> Enum.map(&EventOptions.format_option(&1))

    conn
    |> render(:event, narrative: location_narrative, options: options)
  end

  def act_on_event(conn, %{"event_id" => event_id}) do
    user = Guardian.Plug.current_resource(conn)
    character = Repo.get_by(Character, user_id: user.id)
    |> Repo.preload(event: [:conditions, :children])
    |> Repo.preload(location: [:events])

    acted_event = event_options(character)
    |> Enum.find(fn (e) -> e.id == event_id end)

    if !Event.perished?(acted_event, character) do
      EffectRunner.run_all_event_effects(acted_event, %{ character: character })
    end

    Repo.insert!(%CharacterEventLogs{ event_id: event_id, character_id: character.id })

    trigger_events = Enum.concat(character.location.events, character.event.children)
    |> Repo.preload([:effects, :conditions])
    |> Enum.filter(fn (event) -> event.cause_type == "trigger" end)
    |> Enum.filter(&ConditionChecker.event_conditions_met?(&1, %{ character: character }))
    |> Enum.reject(&Event.perished?(&1, character))
    |> Enum.each(&EffectRunner.run_all_event_effects(&1, %{ character: character }))

    current_event(conn, %{})
  end

  def event_options(character) do
    Enum.concat(character.location.events, character.event.children)
    |> Repo.preload([:conditions, :effects])
    |> Enum.filter(fn (event) -> event.cause_type == "actionable" end)
    |> Enum.map(&EventOptions.get_options_for(&1, character))
    |> Enum.reject(fn (v) -> v == nil end)
    |> Enum.reject(&Event.perished?(&1, character))
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
  def event_conditions_met?(event, resources) do
    event.conditions
    |> Enum.all?(fn (con) ->
      ConditionChecker.check(
        con.key,
        con.payload,
        resources.character
      )
    end)
  end

  def check("hasCredits", %{ quantity: minCredits }, %{ credits: credits }) do
    credits >= minCredits
  end
end

defmodule CloudCogs.EffectRunner do
  def run_all_event_effects(event, %{ character: character }) do
    event.effects
    |> Enum.each(fn (effect) ->
      perform_effect(effect.key, effect.payload, %{ character: character, event: event })
    end)
  end

  def perform_effect("setLocationTo", %{ model_id: model_id }, %{ character: character }) do
    update_character(character, :location_id, model_id)
  end

  def perform_effect("setEventTo", %{ model_id: model_id }, %{ character: character }) do
    update_character(character, :event_id, model_id)
  end

  def perform_effect("narratives", %{ narrative: narratives }, %{ character: character, event: event }) do
    narratives |>
      Enum.map(fn (narrative_text) ->
        %CharacterLocationNarrative{
          character_id: character.id,
          location_id: event.location_id,
          narrative_text: narrative_text
    }
    end)
    |> Enum.each(&Repo.insert!(&1))
  end

  def perform_effect("removeCredits", %{ quantity: credits }, %{ character: character }) do
    update_character(character, :credits, (character.credits - credits))
  end

  def perform_effect("addCredits", %{ quantity: credits }, %{ character: character }) do
    update_character(character, :credits, (character.credits + credits))
  end

  defp update_character(character, key, val) do
    Character.changeset(character, %{ key => val }) |> Repo.update!
  end
end
