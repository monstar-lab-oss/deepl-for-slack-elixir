defmodule DeepThought.Slack.Helper.MessageEscapeTest do
  @moduledoc """
  Test suite to verify the functionality of message escaping prior to sending the text to the translation service.
  """

  use ExUnit.Case, async: true
  alias DeepThought.Slack.Helper.MessageEscape

  test "escape/1 wraps emoji in <emoji> tag" do
    original = """
    A simple message :email::thinking_face: with an emoji :rolling_on_the_floor_laughing: And some text at the end
    """

    expected = """
    A simple message <emoji>:email:</emoji><emoji>:thinking_face:</emoji> with an emoji <emoji>:rolling_on_the_floor_laughing:</emoji> And some text at the end
    """

    assert expected == MessageEscape.escape(original)
  end
end
