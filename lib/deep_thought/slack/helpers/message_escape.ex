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
      |> remove_global_mentions
      |> escape_emoji

  @spec remove_global_mentions(String.t()) :: String.t()
  defp remove_global_mentions(text), do: Regex.replace(~r/<!(?:channel|here)> ?/ui, text, "")

  @spec escape_emoji(String.t()) :: String.t()
  defp escape_emoji(text),
    do:
      Regex.replace(~r/(:(?![\n])[()#$@\-\w]+:)/ui, text, fn _, emoji ->
        "<emoji>" <> emoji <> "</emoji>"
      end)
end
