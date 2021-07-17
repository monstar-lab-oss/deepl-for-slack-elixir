defmodule DeepThought.Slack.MessageEscapeTest do
  @moduledoc """
  Test suite to verify the functionality of message escaping prior to sending the text to the translation service.
  """

  use ExUnit.Case, async: true
  alias DeepThought.Slack.MessageEscape

  test "escape/1 removes global mentions" do
    original = """
    This<!channel>message <!here>is <!everyone>intentionally <!channel> annoying<!here>\
    """

    expected = "Thismessage is intentionally annoying"

    assert expected == MessageEscape.escape(original)
  end

  test "escape/1 wraps emoji" do
    original = """
    A simple message :email::thinking_face: with an emoji :rolling_on_the_floor_laughing: And some text at the end\
    """

    expected = """
    A simple message <e>:email:</e><e>:thinking_face:</e> with an emoji <e>:rolling_on_the_floor_laughing:</e> And some text at the end\
    """

    assert expected == MessageEscape.escape(original)
  end

  test "escape/1 wraps emoji, nightmare difficulty" do
    messages = [
      %{original: ":any-non-whitespace:", expected: "<e>:any-non-whitespace:</e>"},
      %{original: ":text1:sample2:", expected: "<e>:text1:</e>sample2:"},
      %{original: ":@(1@#$@SD: :s:", expected: "<e>:@(1@#$@SD:</e> <e>:s:</e>"},
      %{
        original: ":nospace::inbetween: because there are 2 colons in the middle",
        expected: "<e>:nospace:</e><e>:inbetween:</e> because there are 2 colons in the middle"
      },
      %{original: ":nospace:middle:nospace:", expected: "<e>:nospace:</e>middle<e>:nospace:</e>"}
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
    This message <u>@U9FE1J23V</u> contains some <u>@U0233M3T96K</u> usernames <u>@U0171KB36DN</u><u>@U0233M3T96K</u>And ends with text\
    """

    assert expected == MessageEscape.escape(original)
  end

  test "escape/1 wraps channel names" do
    original = """
    Similarly, <#C023P3L5WFN|deep-thought> this message <#C024C2HU4BZ>references a bunch <#C023P3L5WFN|deep-thought><#C024C2HU4BZ|yakun>of channels\
    """

    expected = """
    Similarly, <c>#C023P3L5WFN</c> this message <c>#C024C2HU4BZ</c>references a bunch <c>#C023P3L5WFN</c><c>#C024C2HU4BZ</c>of channels\
    """

    assert expected == MessageEscape.escape(original)
  end

  test "escape/1 wraps links" do
    original = """
    This <https://www.milanvit.net> message contains <https://www.milanvit.net|Czech/in/Japan> links. To e-mail <mailto:milanvit@milanvit.net> as well? <mailto:milanvit@milanvit.net|You bet.>\
    """

    expected = """
    This <l>https://www.milanvit.net</l> message contains <l>https://www.milanvit.net|Czech/in/Japan</l> links. To e-mail <l>mailto:milanvit@milanvit.net</l> as well? <l>mailto:milanvit@milanvit.net|You bet.</l>\
    """

    assert expected == MessageEscape.escape(original)
  end

  test "escape/1 wraps codeblocks" do
    original = """
    This message contains a codeblock:
    ```awesome |&gt; elixir |&gt; code```
    This is also a valid codeblock:
    ```say |> no |> to |> go ```\
    """

    expected = """
    This message contains a codeblock:
    <d>```awesome |&gt; elixir |&gt; code```</d>
    This is also a valid codeblock:
    <d>```say |> no |> to |> go ```</d>\
    """

    assert expected == MessageEscape.escape(original)
  end

  test "escape/1 wraps inline code" do
    original = """
    This message `contains` in-line `code`, in quite `a bit` of various `forms`,`this one is fine`,`and so is this one`, but what about if we `make things` really difficult`?\
    """

    expected = """
    This message <d>`contains`</d> in-line <d>`code`</d>, in quite <d>`a bit`</d> of various <d>`forms`</d>,<d>`this one is fine`</d>,<d>`and so is this one`</d>, but what about if we <d>`make things`</d> really difficult`?\
    """

    assert expected == MessageEscape.escape(original)
  end
end
