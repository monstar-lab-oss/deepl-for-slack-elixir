defmodule DeepThought.Slack.LanguageTest do
  @moduledoc """
  Test suite for a module that converts between country codes and language codes.
  """

  use ExUnit.Case, async: true

  alias DeepThought.Slack.Language

  test "new/1 returns a language struct for valid language code" do
    ["cz", "us", "gb", "jp", "pl"]
    |> Stream.map(&"flag-#{&1}")
    |> Enum.each(fn reaction ->
      assert {:ok, %Language{slack_code: slack_code, deepl_code: deepl_code}} =
               Language.new(reaction)

      assert String.ends_with?(reaction, slack_code)
      assert String.upcase(deepl_code) == deepl_code
      refute deepl_code == ""
    end)
  end

  test "new/1 returns error on invalid language code" do
    Enum.each(["", "invalid", "🤣", "ne", "ng"], fn reaction ->
      assert {:error, :unknown_language} == Language.new(reaction)
    end)
  end
end
