defmodule DeepThought.Slack.Handler.Translate do
  @moduledoc """
  Module responsible for handling the `/translate` Slack command, determining the target language and securing the
  translation, incl. all required escaping and unescaping.
  """

  alias DeepThought.DeepL
  alias DeepThought.Slack
  alias DeepThought.Slack.API.Message
  alias DeepThought.Slack.{Language, MessageEscape}

  @doc """
  Translates the given text into the target language.
  """
  @typep reason() :: :missing_text | :unknown_language
  @spec translate(map()) :: {:ok, String.t()} | {:error, reason()} | Slack.API.api_error()
  def translate(%{
        "channel_id" => channel_id,
        "text" => params,
        "user_id" => user_id,
        "user_name" => username
      }) do
    with [language, original_text] <- String.split(params, " ", parts: 2),
         {:ok, %{deepl_code: language_code}} <- Language.new(String.trim(language, ":")),
         escaped_text <- MessageEscape.escape(original_text),
         {_, translation} <- DeepL.API.translate(escaped_text, language_code),
         {:ok, message} <- say_in_channel(channel_id, username, original_text, translation) do
      {:ok, message}
    else
      [_language] ->
        handle_missing_text(channel_id, user_id)

        {:error, :missing_text}

      {:error, :unknown_language} = error ->
        handle_unknown_language(channel_id, user_id)
        error

      error ->
        error
    end
  end

  @spec say_in_channel(String.t(), String.t(), String.t(), String.t()) ::
          {:ok, String.t()} | Slack.API.api_error()
  def say_in_channel(channel_id, username, original_text, translation) do
    message_text = """
    _@#{username}_ asked me to translate this: #{original_text}
    Translation: #{translation}\
    """

    case Message.new(message_text, channel_id)
         |> Message.unescape()
         |> Slack.API.chat_post_message() do
      {:ok, _channel_id, _message_ts} -> {:ok, message_text}
      error -> error
    end
  end

  @spec handle_missing_text(String.t(), String.t()) :: :ok | Slack.API.api_error()
  defp handle_missing_text(channel_id, user_id),
    do:
      Message.new(
        """
        Did you forget to submit the text to translate?

        If unsure, type `/translate` to see usage instructions!\
        """,
        channel_id
      )
      |> Message.for_user(user_id)
      |> Slack.API.chat_post_ephemeral()

  @spec handle_unknown_language(String.t(), String.t()) :: :ok | Slack.API.api_error()
  defp handle_unknown_language(channel_id, user_id),
    do:
      Message.new("Sorry, I don’t know that language yet!", channel_id)
      |> Message.for_user(user_id)
      |> Slack.API.chat_post_ephemeral()
end
