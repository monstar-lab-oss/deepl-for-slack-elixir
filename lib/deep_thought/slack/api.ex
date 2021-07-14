defmodule DeepThought.Slack.API do
  @moduledoc """
  Module used to interact with the Slack API.
  """

  use Tesla
  alias DeepThought.Slack.API.Message

  plug Tesla.Middleware.BaseUrl, "https://slack.com/api"
  plug Tesla.Middleware.Headers, [{"Authorization", bearer_token()}]
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Logger

  @doc """
  Post a message in a Slack channel or, when supplied a valid `thread_ts`, in a discussion thread.
  """
  @spec chat_post_message(Message.t()) :: :ok | {:error, atom()}
  def chat_post_message(message) do
    case post("/chat.postMessage", message) do
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

  @doc """
  Query Slack API to return user profile for a given user ID.
  """
  @spec users_profile_get(String.t()) :: {:ok, map()} | {:error, non_neg_integer() | atom()}
  def users_profile_get(user_id) do
    case get("/users.profile.get", query: [user: user_id]) do
      {:ok, response} ->
        case response.status() do
          200 -> {:ok, response.body()["profile"]}
          code -> {:error, code}
        end

      error ->
        error
    end
  end

  @spec bearer_token() :: String.t()
  defp bearer_token, do: "Bearer " <> Application.get_env(:deep_thought, :slack)[:bot_token]
end
