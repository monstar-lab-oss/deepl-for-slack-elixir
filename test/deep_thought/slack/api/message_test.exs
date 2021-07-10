defmodule DeepThought.Slack.API.MessageTest do
  @moduledoc """
  Test suite to verify the Message module, especially its unescaping logic.
  """

  use ExUnit.Case, async: true
  alias DeepThought.Slack.API.Message

  test "unescape/1 unwraps emoji" do
    original = """
    A simple message <emoji>:email:</emoji><emoji>:thinking_face:</emoji> with an emoji <emoji>:rolling_on_the_floor_laughing:</emoji> And some text at the end\
    """

    expected = """
    A simple message :email::thinking_face: with an emoji :rolling_on_the_floor_laughing: And some text at the end\
    """

    assert %{text: ^expected} = Message.new(original, "") |> Message.unescape()
  end
end
