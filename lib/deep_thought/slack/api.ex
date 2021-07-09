defmodule DeepThought.Slack.API do
  @moduledoc """
  Module used to interact with the Slack API.
  """

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://slack.com/api"
  plug Tesla.Middleware.Headers, [{"Authorization", bearer_token()}]
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Logger

  @doc """
  Post a message in a Slack channel or, when supplied a valid `thread_ts`, in a discussion thread.
  """
  @spec chat_post_message(String.t(), String.t(), list()) :: :ok | {:error, atom()}
  def chat_post_message(channel_id, text, opts \\ []) do
    case post("/chat.postMessage", Map.merge(%{channel: channel_id, text: text}, Map.new(opts))) do
      {:ok, _response} -> :ok
      error -> error
    end
  end

  @doc """
  Query Slack API to return a conversation history given a specified channel ID and timestamp, which are both obtained
  typically from an Events API event.
  """
  @spec conversations_replies(String.t(), String.t(), boolean()) ::
          {:ok, [map()]} | {:error, non_neg_integer() | atom()}
  def conversations_replies(channel_id, message_ts, inclusive \\ true) do
    case get("/conversations.replies",
           query: [channel: channel_id, ts: message_ts, inclusive: inclusive]
         ) do
      {:ok, response} ->
        case response.status() do
          200 -> {:ok, response.body()["messages"]}
          code -> {:error, code}
        end

      error ->
        error
    end
  end

  @spec bearer_token() :: String.t()
  defp bearer_token, do: "Bearer " <> Application.get_env(:deep_thought, :slack)[:bot_token]
end
