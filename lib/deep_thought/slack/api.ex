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
  Query Slack API for permalink to a given message in a channel.
  """
  @type api_error :: {:error, atom() | non_neg_integer() | String.t()}
  @spec chat_get_permalink(String.t(), String.t()) :: {:ok, String.t()} | api_error()
  def chat_get_permalink(channel_id, message_ts) do
    case get("/chat.getPermalink", query: [channel: channel_id, message_ts: message_ts]) do
      {:ok, response} ->
        case {response.status(), response.body()["ok"]} do
          {200, true} -> {:ok, response.body()["permalink"]}
          {_, false} -> {:error, response.body()["error"]}
          {code, _} -> {:error, code}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Ask Slack API to delete a message.
  """
  @spec chat_delete(String.t(), String.t()) :: :ok | api_error()
  def chat_delete(channel_id, message_ts) do
    case post("/chat.delete", %{channel: channel_id, ts: message_ts}) do
      {:ok, response} ->
        case {response.status(), response.body()["ok"]} do
          {200, true} -> :ok
          {_, false} -> {:error, response.body()["error"]}
          {code, _} -> {:error, code}
        end

      error ->
        error
    end
  end

  @doc """
  Post a Slack ephemeral message, which is visible only to a specific user.
  """
  @spec chat_post_ephemeral(Message.t()) :: :ok | api_error()
  def chat_post_ephemeral(message) do
    case post("/chat.postEphemeral", message) do
      {:ok, response} ->
        case {response.status(), response.body()["ok"]} do
          {200, true} -> :ok
          {_, false} -> {:error, response.body()["error"]}
          {code, _} -> {:error, code}
        end

      error ->
        error
    end
  end

  @doc """
  Post a message in a Slack channel or, when supplied a valid `thread_ts`, in a discussion thread. In case of success,
  returns channel ID and message TS of the posted message.
  """
  @spec chat_post_message(Message.t()) :: {:ok, String.t(), String.t()} | api_error()
  def chat_post_message(message) do
    case post("/chat.postMessage", message) do
      {:ok, response} ->
        case {response.status(), response.body()["ok"]} do
          {200, true} -> {:ok, response.body()["channel"], response.body()["ts"]}
          {_, false} -> {:error, response.body()["error"]}
          {code, _} -> {:error, code}
        end

      error ->
        error
    end
  end

  @doc """
  Query Slack API to return a conversation history given a specified channel ID and timestamp, which are both obtained
  typically from an Events API event.
  """
  @spec conversations_replies(String.t(), String.t(), boolean()) :: {:ok, [map()]} | api_error()
  def conversations_replies(channel_id, message_ts, inclusive \\ true) do
    case get("/conversations.replies",
           query: [channel: channel_id, ts: message_ts, inclusive: inclusive]
         ) do
      {:ok, response} ->
        case {response.status(), response.body()["ok"]} do
          {200, true} -> {:ok, response.body()["messages"]}
          {_, false} -> {:error, response.body()["error"]}
          {code, _} -> {:error, code}
        end

      error ->
        error
    end
  end

  @doc """
  Query Slack API to return user profile for a given user ID.
  """
  @spec users_profile_get(String.t()) :: {:ok, map()} | api_error()
  def users_profile_get(user_id) do
    case get("/users.profile.get", query: [user: user_id]) do
      {:ok, response} ->
        case {response.status(), response.body()["ok"]} do
          {200, true} -> {:ok, response.body()["profile"]}
          {_, false} -> {:error, response.body()["error"]}
          {code, _} -> {:error, code}
        end

      error ->
        error
    end
  end

  @spec bearer_token() :: String.t()
  defp bearer_token, do: "Bearer " <> Application.get_env(:deep_thought, :slack)[:bot_token]
end
