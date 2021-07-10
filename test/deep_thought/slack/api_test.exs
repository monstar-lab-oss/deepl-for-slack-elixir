defmodule DeepThought.Slack.APITest do
  @moduledoc """
  Module used to test the interaction with the Slack API.
  """

  use DeepThought.MockCase, async: true
  alias DeepThought.Slack.API.Message

  test "chat_post_message/3 can post a message" do
    assert :ok == Slack.API.chat_post_message(Message.new("text", "channel_id"))
  end

  test "conversations_replies/3 can fetch message with its details" do
    assert {:ok, [%{"text" => "Hello, world!"} | _rest]} =
             Slack.API.conversations_replies("channel_id", "ts")
  end
end
