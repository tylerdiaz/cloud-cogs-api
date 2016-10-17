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

alias CloudCogs.{Character, Repo, User, Location, Item, Event, EventEffect, EventCondition}

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
[
  %Event{
    name: "The beginning",
    cause_type: "trigger",
    location_id: Repo.get_by(Location, name: "Sleeping Quarters").id,
    effects: [
      %EventEffect{
        key: "narrative",
        payload: %{entries: ["Something happens", "You wake up", "What do you do"]}
      }
    ],
    conditions: [],
    children: [
      %Event{
        name: "After the beginning",
        cause_type: "trigger",
        action_label: "Continue",
        location_id: Repo.get_by(Location, name: "Sleeping Quarters").id,
        effects: [
          %EventEffect{
            key: "narrative",
            payload: %{entries: ["Something happens"]}
          }
        ],
        conditions: []
      },
      %Event{
        name: "After the beginning",
        cause_type: "trigger",
        action_label: "Fall down",
        location_id: Repo.get_by(Location, name: "Sleeping Quarters").id,
        effects: [
          %EventEffect{
            key: "narrative",
            payload: %{entries: ["Another thing happens"]}
          }
        ],
        conditions: []
      }
    ]
  }
]
|> Enum.each(&Repo.insert!(&1))

%Character{
  user_id: Repo.get_by(User, username: "admin").id,
  credits: 100,
  energy: 100,
  max_energy: 100,
  location_id: Repo.get_by(Location, name: "Sleeping Quarters").id,
  event_id: Repo.get_by(Event, name: "The beginning").id
}
|> Repo.insert!

# Repo.get_by(Event, name: "The beginning").id,
#   Repo.get_by(Location, name: "Sleeping Quarters").id,
