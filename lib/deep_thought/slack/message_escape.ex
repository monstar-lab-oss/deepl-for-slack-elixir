defmodule DeepThought.Slack.MessageEscape do
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
      |> escape_emojis
      |> escape_usernames
      |> escape_channels

  @spec remove_global_mentions(String.t()) :: String.t()
  defp remove_global_mentions(text),
    do: Regex.replace(~r/<!(?:channel|here|everyone)(?:\|\S+?)?> ?/ui, text, "")

  @spec escape_emojis(String.t()) :: String.t()
  defp escape_emojis(text),
    do:
      Regex.replace(~r/(:(?![\n])[()#$@\-\w]+:)/ui, text, fn _, emoji ->
        "<emoji>" <> emoji <> "</emoji>"
      end)

  @spec escape_usernames(String.t()) :: String.t()
  def escape_usernames(text),
    do:
      Regex.replace(~r/<(@[UW]\w+?)(?:\|\S+?)?>/ui, text, fn _, username ->
        "<username>" <> username <> "</username>"
      end)

  @spec escape_channels(String.t()) :: String.t()
  def escape_channels(text),
    do:
      Regex.replace(~r/<(#C\w+)(?:\|\S+?)?>/ui, text, fn _, channel_id ->
        "<channel>" <> channel_id <> "</channel>"
      end)
end
