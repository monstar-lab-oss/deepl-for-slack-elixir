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

  test "unescape/1 unwraps usernames" do
    original = """
    This message <username>@U9FE1J23V</username> contains some <username>@U0233M3T96K</username> usernames <username>@U0171KB36DN</username><username>@U0233M3T96K</username>And ends with text\
    """

    expected = """
    This message _Milan Vít_ contains some _Deep Thought_ usernames _dokku_ _Deep Thought_ And ends with text\
    """

    assert %{text: ^expected} = Message.new(original, "") |> Message.unescape()
  end

  test "unescape/1 unwraps channel names" do
    original = """
    Similarly, <channel>#C023P3L5WFN</channel> this message <channel>#C024C2HU4BZ</channel>references a bunch <channel>#C023P3L5WFN</channel><channel>#C024C2HU4BZ</channel>of channels\
    """

    expected = """
    Similarly, <#C023P3L5WFN> this message <#C024C2HU4BZ>references a bunch <#C023P3L5WFN><#C024C2HU4BZ>of channels\
    """

    assert %{text: ^expected} = Message.new(original, "") |> Message.unescape()
  end

  test "unescape/1 unwraps links" do
    original = """
    This <link>https://www.milanvit.net</link> message contains <link>https://www.milanvit.net|Czech/in/Japan</link> links. To e-mail <link>mailto:milanvit@milanvit.net</link> as well? <link>mailto:milanvit@milanvit.net|You bet.</link>\
    """

    expected = """
    This <https://www.milanvit.net> message contains <https://www.milanvit.net|Czech/in/Japan> links. To e-mail <mailto:milanvit@milanvit.net> as well? <mailto:milanvit@milanvit.net|You bet.>\
    """

    assert %{text: ^expected} = Message.new(original, "") |> Message.unescape()
  end
end
