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
      |> escape_links
      |> escape_code

  @spec remove_global_mentions(String.t()) :: String.t()
  defp remove_global_mentions(text),
    do: Regex.replace(~r/<!(?:channel|here|everyone)(?:\|.+?)?> ?/ui, text, "")

  @spec escape_emojis(String.t()) :: String.t()
  defp escape_emojis(text),
    do:
      Regex.replace(~r/(:(?![\n])[()#$@\-\w]+:)/ui, text, fn _, emoji ->
        "<emoji>" <> emoji <> "</emoji>"
      end)

  @spec escape_usernames(String.t()) :: String.t()
  defp escape_usernames(text),
    do:
      Regex.replace(~r/<(@[UW]\w+?)(?:\|.+?)?>/ui, text, fn _, username ->
        "<username>" <> username <> "</username>"
      end)

  @spec escape_channels(String.t()) :: String.t()
  defp escape_channels(text),
    do:
      Regex.replace(~r/<(#C\w+)(?:\|.+?)?>/ui, text, fn _, channel_id ->
        "<channel>" <> channel_id <> "</channel>"
      end)

  @spec escape_links(String.t()) :: String.t()
  defp escape_links(text),
    # credo:disable-for-lines:3
    do:
      Regex.replace(
        ~r/<((?:mailto:\S+?@\S+?(?:\|.+?)?)|(?:https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})(?:\|.+?)?)>/ui,
        text,
        fn _, link ->
          "<link>" <> link <> "</link>"
        end
      )

  @spec escape_code(String.t()) :: String.t()
  defp escape_code(text),
    do:
      text
      |> escape_codeblocks()
      |> escape_inline_code()

  @spec escape_codeblocks(String.t()) :: String.t()
  defp escape_codeblocks(text),
    do:
      Regex.replace(~r/(^```.+?```$)/mui, text, fn _, code ->
        "<code>" <> code <> "</code>"
      end)

  @spec escape_inline_code(String.t()) :: String.t()
  defp escape_inline_code(text),
    do:
      Regex.replace(~r/(?<![`>])(`.+?`)(?![`<])/ui, text, fn _, code ->
        "<code>" <> code <> "</code>"
      end)
end
