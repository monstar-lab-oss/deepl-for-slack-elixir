defmodule DeepThought.Slack.API.MessageTest do
  @moduledoc """
  Test suite to verify the Message module, especially its unescaping logic.
  """

  use DeepThought.DataCase
  alias DeepThought.Slack
  alias DeepThought.Slack.API.Message

  setup do
    Slack.update_users!([
      %{"user_id" => "U9FE1J23V", "real_name" => "Milan Vít"},
      %{"user_id" => "U0233M3T96K", "real_name" => "Deep Thought"},
      %{"user_id" => "U0171KB36DN", "display_name" => "dokku"}
    ])

    :ok
  end

  test "unescape/1 unwraps emoji" do
    original = """
    A simple message <e>:email:</e><e>:thinking_face:</e> with an emoji <e>:rolling_on_the_floor_laughing:</e> And some text at the end\
    """

    expected = """
    A simple message :email::thinking_face: with an emoji :rolling_on_the_floor_laughing: And some text at the end\
    """

    assert %{text: ^expected} = Message.new(original, "") |> Message.unescape()
  end

  test "unescape/1 unwraps usernames" do
    original = """
    This message <u>@U9FE1J23V</u> contains some <u>@U0233M3T96K</u> usernames <u>@U0171KB36DN</u><u>@U0233M3T96K</u>And ends with text\
    """

    expected = """
    This message _Milan Vít_ contains some _Deep Thought_ usernames _dokku_ _Deep Thought_ And ends with text\
    """

    assert %{text: ^expected} = Message.new(original, "") |> Message.unescape()
  end

  test "unescape/1 unwraps channel names" do
    original = """
    Similarly, <c>#C023P3L5WFN</c> this message <c>#C024C2HU4BZ</c>references a bunch <c>#C023P3L5WFN</c><c>#C024C2HU4BZ</c>of channels\
    """

    expected = """
    Similarly, <#C023P3L5WFN> this message <#C024C2HU4BZ>references a bunch <#C023P3L5WFN><#C024C2HU4BZ>of channels\
    """

    assert %{text: ^expected} = Message.new(original, "") |> Message.unescape()
  end

  test "unescape/1 unwraps links" do
    original = """
    This <l>https://www.milanvit.net</l> message contains <l>https://www.milanvit.net|Czech/in/Japan</l> links. To e-mail <l>mailto:milanvit@milanvit.net</l> as well? <l>mailto:milanvit@milanvit.net|You bet.</l>\
    """

    expected = """
    This <https://www.milanvit.net> message contains <https://www.milanvit.net|Czech/in/Japan> links. To e-mail <mailto:milanvit@milanvit.net> as well? <mailto:milanvit@milanvit.net|You bet.>\
    """

    assert %{text: ^expected} = Message.new(original, "") |> Message.unescape()
  end

  test "unescape/1 unwraps codeblocks" do
    original = """
    This message contains a codeblock:
    <d>```awesome |&gt; elixir |&gt; code```</d>
    This is also a valid codeblock:
    <d>```say |> no |> to |> go ```</d>\
    """

    expected = """
    This message contains a codeblock:
    ```awesome |&gt; elixir |&gt; code```
    This is also a valid codeblock:
    ```say |> no |> to |> go ```\
    """

    assert %{text: ^expected} = Message.new(original, "") |> Message.unescape()
  end

  test "unescape/1 unwraps inline code" do
    original = """
    This message <d>`contains`</d> in-line <d>`code`</d>, in quite <d>`a bit`</d> of various <d>`forms`</d>,<d>`this one is fine`</d>,<d>`and so is this one`</d>, but what about if we <d>`make things`</d> really difficult`?\
    """

    expected = """
    This message `contains` in-line `code`, in quite `a bit` of various `forms`, `this one is fine`, `and so is this one`, but what about if we `make things` really difficult`?\
    """

    assert %{text: ^expected} = Message.new(original, "") |> Message.unescape()
  end
end
