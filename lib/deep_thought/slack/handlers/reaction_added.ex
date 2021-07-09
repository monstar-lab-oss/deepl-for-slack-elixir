defmodule DeepThought.Slack.Handler.ReactionAdded do
  @moduledoc """
  Module responsible for handling the `reaction_added` Slack event, which is received when user adds a reaction emoji to
  a message. This might be a normal emoji, or a flag emoji, which would indicate the desire to translate the message to
  another language.
  """

  alias DeepThought.DeepL
  alias DeepThought.Slack
  alias DeepThought.Slack.Language

  @doc """
  Take event details, interpret the details, if the event points to a translation request, fetch the message details,
  translate the message text and post the translation in thread.
  """
  @typep reason() :: :unknown_language | non_neg_integer() | atom()
  @spec reaction_added(map()) :: {:ok, String.t()} | {:error, reason()}
  def reaction_added(%{
        "item" => %{"channel" => channel_id, "ts" => message_ts, "type" => "message"},
        "reaction" => reaction
      }) do
    with {:ok, %{deepl_code: language_code}} <- Language.new(reaction),
         {:ok, [%{"text" => original} = message | _]} <- Slack.API.conversations_replies(channel_id, message_ts),
         {_, translation} <- DeepL.API.translate(original, language_code),
         :ok <- say_in_thread(channel_id, translation, message) do
          {:ok, translation}
    else
      error -> error
    end
  end

  @spec say_in_thread(String.t(), String.t(), map()) :: :ok | {:error, atom()}
  defp say_in_thread(channel_id, translation, message) do
    Slack.API.chat_post_message(channel_id, translation, thread_ts: extract_thread_ts(message))
  end

  @spec extract_thread_ts(map()) :: String.t()
  defp extract_thread_ts(%{"thread_ts" => thread_ts}), do: thread_ts
  defp extract_thread_ts(%{"ts" => ts}), do: ts
end
