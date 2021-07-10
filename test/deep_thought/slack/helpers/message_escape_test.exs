defmodule DeepThought.Slack.Helper.MessageEscapeTest do
  @moduledoc """
  Test suite to verify the functionality of message escaping prior to sending the text to the translation service.
  """

  use ExUnit.Case, async: true
  alias DeepThought.Slack.Helper.MessageEscape

  test "escape/1 removes global mentions" do
    original = "This<!channel>message <!here>is intentionally <!channel> annoying<!here>"
    expected = "Thismessage is intentionally annoying"

    assert expected == MessageEscape.escape(original)
  end

  test "escape/1 wraps emoji in <emoji> tag" do
    original = """
    A simple message :email::thinking_face: with an emoji :rolling_on_the_floor_laughing: And some text at the end\
    """

    expected = """
    A simple message <emoji>:email:</emoji><emoji>:thinking_face:</emoji> with an emoji <emoji>:rolling_on_the_floor_laughing:</emoji> And some text at the end\
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

  test "escape/1 wraps usernames" do
    original = """
    This message <@U9FE1J23V> contains some <@U0233M3T96K> usernames <@U0171KB36DN><@U0233M3T96K>And ends with text\
    """

    expected = """
    This message <username>@U9FE1J23V</username> contains some <username>@U0233M3T96K</username> usernames <username>@U0171KB36DN</username><username>@U0233M3T96K</username>And ends with text\
    """

    assert expected == MessageEscape.escape(original)
  end

  test "escape/1 wraps channel names" do
    original = """
    Similarly, <#C023P3L5WFN|deep-thought> this message <#C024C2HU4BZ|yakun>references a bunch <#C023P3L5WFN|deep-thought><#C024C2HU4BZ|yakun>of channels\
    """

    expected = """
    Similarly, <channel>#C023P3L5WFN|deep-thought</channel> this message <channel>#C024C2HU4BZ|yakun</channel>references a bunch <channel>#C023P3L5WFN|deep-thought</channel><channel>#C024C2HU4BZ|yakun</channel>of channels\
    """

    assert expected == MessageEscape.escape(original)
  end
end
