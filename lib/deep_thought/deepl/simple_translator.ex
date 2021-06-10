defmodule DeepThought.DeepL.SimpleTranslator do
  alias DeepThought.DeepL
  alias DeepThought.Slack
  alias DeepThought.Slack.LanguageConverter

  def simple_translate(channel_id, text, username, user_id) do
    [target_language, message_text] = String.split(text, " ", parts: 2)

    case String.trim(target_language, ":")
         |> LanguageConverter.reaction_to_lang() do
      {:ok, target_language} ->
        {:ok, translation} = DeepL.API.translate(message_text, target_language)

        generate_message(translation, message_text, username)
        |> say_in_channel(channel_id)

      :error ->
        unsupported_language()
        |> say_privately(channel_id, user_id)
    end
  end

  defp say_in_channel(text, channel_id) do
    Slack.API.chat_post_message(channel_id, text)
  end

  defp say_privately(text, channel_id, user_id) do
    Slack.API.chat_post_ephemeral(channel_id, user_id, text)
  end

  defp generate_message(translation, original_message, username) do
    "_@" <>
      username <>
      " asked me to translate this:_ " <>
      translation <> "\n_The original message was:_ " <> original_message
  end

  defp unsupported_language,
    do:
      "Sorry, that doesn’t look like a language I can translate to just yet… " <>
        "Can you please make sure that the first word after the `/translate` command is a language shorthand or flag emoji?"
end
