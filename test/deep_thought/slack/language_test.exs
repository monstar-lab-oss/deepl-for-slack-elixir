defmodule DeepThought.Slack.LanguageTest do
  @moduledoc """
  Test suite for a module that converts between country codes and language codes.
  """

  use ExUnit.Case, async: true

  alias DeepThought.Slack.Language

  test "new/1 returns a language struct for valid language code" do
    ["cz", "us", "gb", "jp", "pl"]
    |> Enum.map(fn reaction -> [reaction, "flag-" <> reaction] end)
    |> List.flatten()
    |> Enum.each(fn reaction ->
      assert {:ok, %Language{slack_code: slack_code, deepl_code: deepl_code}} =
               Language.new(reaction)

      assert String.ends_with?(reaction, slack_code)
      assert String.upcase(deepl_code) == deepl_code
      refute deepl_code == ""
    end)
  end

  test "new/1 returns error on invalid language code" do
    Enum.each(["", "invalid", "🤣"], fn reaction ->
      assert {:error, :unknown_language} == Language.new(reaction)
    end)
  end

  test "new/1 works with edge cases" do
    assert {:error, :unknown_language} = Language.new("ng")
    assert {:ok, %Language{deepl_code: "EN-US"}} = Language.new("flag-ng")
    assert {:error, :unknown_language} = Language.new("ne")
    assert {:ok, %Language{deepl_code: "FR"}} = Language.new("flag-ne")
  end
end
