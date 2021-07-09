defmodule DeepThought.Slack.Helper.MessageEscape do
  @moduledoc """
  Helper module which takes a Slack message in the form of a string (as returned from the `conversations.replies` API
  method) and escapes its content in such a way that the likelihood of all important pieces of information to survive
  the translation process is increased to maximum.
  """

  @doc """
  Execute the escaping pipeline on a given string.
  """
  @spec escape(String.t()) :: String.t()
  def escape(text),
    do:
      text
      |> escape_emoji

  @spec escape_emoji(String.t()) :: String.t()
  defp escape_emoji(text),
    do:
      Regex.replace(~r/(:\S+:)/ui, text, fn _, emoji ->
        "<emoji>" <> emoji <> "</emoji>"
      end)
end
