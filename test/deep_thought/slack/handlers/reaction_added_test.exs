defmodule DeepThought.Slack.Handler.ReactionAddedTest do
  @moduledoc """
  Test suite for the reaction_added event handler.
  """

  use DeepThought.DataCase
  use DeepThought.MockCase
  alias DeepThought.Slack.Handler.ReactionAdded

  @event %{
    "type" => "reaction_added",
    "user" => "U9FE1J23V",
    "item" => %{
      "type" => "message",
      "channel" => "C023P3L5WFN",
      "ts" => "1622775072.008900"
    },
    "reaction" => "flag-cz",
    "item_user" => "U9FE1J23V",
    "event_ts" => "1625226531.000200"
  }

  test "reaction_added/1 returns a translation based on event data" do
    assert {:ok, "Ahoj, světe!"} == ReactionAdded.reaction_added(@event)
  end

  test "reaction_added/1 ignores emoji reactions that are not flags" do
    event = Map.put(@event, "reaction", "rolling_on_the_floor_laughing")
    assert {:error, :unknown_language} == ReactionAdded.reaction_added(event)
  end

  test "reaction_added/1 ignores emoji flags of unsupported languages" do
    event = Map.put(@event, "reaction", "flag-sa")
    assert {:error, :unknown_language} == ReactionAdded.reaction_added(event)
  end
end
