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

  test "escape/1 wraps emoji, nightmare difficulty" do
    messages = [
      %{original: ":any-non-whitespace:", expected: "<emoji>:any-non-whitespace:</emoji>"},
      %{original: ":text1:sample2:", expected: "<emoji>:text1:</emoji>sample2:"},
      %{original: ":@(1@#$@SD: :s:", expected: "<emoji>:@(1@#$@SD:</emoji> <emoji>:s:</emoji>"},
      %{
        original: ":nospace::inbetween: because there are 2 colons in the middle",
        expected:
          "<emoji>:nospace:</emoji><emoji>:inbetween:</emoji> because there are 2 colons in the middle"
      },
      %{
        original: ":nospace:middle:nospace:",
        expected: "<emoji>:nospace:</emoji>middle<emoji>:nospace:</emoji>"
      }
    ]

    Enum.each(messages, fn message ->
      assert message.expected == MessageEscape.escape(message.original)
    end)
  end
end
