defmodule DeepThought.DeepL.SimpleTranslator do
  alias DeepThought.DeepL
  alias DeepThought.Slack
  alias DeepThought.Slack.LanguageConverter

  def simple_translate(channel_id, text, username) do
    [target_language, message_text] = String.split(text, " ", parts: 2)

    {:ok, target_language} =
      String.trim(target_language, ":")
      |> LanguageConverter.reaction_to_lang()

    {:ok, translation} = DeepL.API.translate(message_text, target_language)

    generate_message(translation, message_text, username)
    |> say_in_channel(channel_id)
  end

  defp say_in_channel(text, channel_id) do
    Slack.API.chat_post_message(channel_id, text)
  end

  defp generate_message(translation, original_message, username) do
    "_@" <>
      username <>
      " asked me to translate this:_ " <>
      translation <> "\n_The original message was:_ " <> original_message
  end
end
