defmodule DeepThought.Slack.Handler.TranslateTest do
  @moduledoc """
  Test suite for the /translate command handler.
  """

  use DeepThought.DataCase
  use DeepThought.MockCase
  alias DeepThought.Slack.Handler.Translate

  @command %{
    "channel_id" => "C023P3L5WFN",
    "text" => "",
    "user_id" => "U9FE1J23V",
    "user_name" => "milanvit"
  }

  test "translate/1 returns error on missing text" do
    command = Map.put(@command, "text", ":jp:")

    assert {:error, :missing_text} == Translate.translate(command)
  end

  test "translate/1 returns error on invalid language" do
    command = Map.put(@command, "text", ":hello: Hello world!")

    assert {:error, :unknown_language} == Translate.translate(command)
  end

  test "translate/1 returns translation on success" do
    command = Map.put(@command, "text", ":flag-cz: Hello world!")

    assert {:ok, message} = Translate.translate(command)
    assert message =~ "Hello world!"
    assert message =~ "Ahoj, světe!"
    assert message =~ @command["user_name"]
  end
end
