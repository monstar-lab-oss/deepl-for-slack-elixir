defmodule DeepThought.Slack.APITest do
  @moduledoc """
  Module used to test the interaction with the Slack API.
  """

  use DeepThought.MockCase, async: false
  alias DeepThought.Slack.API.Message

  test "chat_post_message/3 can post a message" do
    assert {:ok, "C1H9RESGA", _ts} = Slack.API.chat_post_message(Message.new("text", "C1H9RESGA"))
  end

  test "conversations_replies/3 can fetch message with its details" do
    assert {:ok, [%{"text" => "Hello, world!"} | _rest]} =
             Slack.API.conversations_replies("channel_id", "ts")
  end

  test "users_profile_get/1 can fetch a user profile" do
    assert {:ok, %{"real_name" => "Milan Vít"}} = Slack.API.users_profile_get("U9FE1J23V")
  end
end
