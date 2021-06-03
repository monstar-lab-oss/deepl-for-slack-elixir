defmodule DeepThought.SlackTest do
  use DeepThought.DataCase

  alias DeepThought.Slack

  describe "events" do
    alias DeepThought.Slack.Event

    @valid_attrs %{type: "some type"}
    @invalid_attrs %{type: nil}

    def event_fixture(attrs \\ %{}) do
      {:ok, event} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Slack.create_event()

      event
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Slack.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = Slack.create_event(@valid_attrs)
      assert event.type == "some type"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Slack.create_event(@invalid_attrs)
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Slack.change_event(event)
    end
  end
end
