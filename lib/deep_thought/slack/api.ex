defmodule DeepThought.Slack.API do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://slack.com/api")

  plug(Tesla.Middleware.Headers, [
    {"Authorization", "Bearer " <> Application.get_env(:deep_thought, :slack)[:bot_token]}
  ])

  plug(Tesla.Middleware.JSON)

  def chat_delete(channel_id, message_ts) do
    case post("/chat.delete", %{channel: channel_id, ts: message_ts}) do
      {:ok, _} -> :ok
      {:error, error} -> {:error, error}
    end
  end

  def chat_get_permalink(channel_id, message_ts) do
    case get("/chat.getPermalink", query: [channel: channel_id, message_ts: message_ts]) do
      {:ok, response} -> {:ok, response.body() |> Map.get("permalink")}
      {:error, error} -> {:error, error}
    end
  end

  def chat_post_ephemeral(channel_id, user_id, text, thread_ts) do
    case post("/chat.postEphemeral", %{
           channel: channel_id,
           user: user_id,
           text: text,
           thread_ts: thread_ts
         }) do
      {:ok, _response} -> :ok
      {:error, error} -> {:error, error}
    end
  end

  def chat_post_message(channel, text, opts \\ %{}) do
    case post("/chat.postMessage", Enum.into(opts, %{channel: channel, text: text})) do
      {:ok, _response} -> :ok
      {:error, error} -> {:error, error}
    end
  end

  def conversations_replies(channel_id, message_ts) do
    case get("/conversations.replies",
           query: [channel: channel_id, ts: message_ts, inclusive: true]
         ) do
      {:ok, response} -> {:ok, response.body() |> Map.get("messages")}
      {:error, error} -> {:error, error}
    end
  end

  def users_profile_get(user_id) do
    case get("/users.profile.get", query: [user: user_id]) do
      {:ok, response} -> {:ok, response.body() |> Map.get("profile")}
      {:error, error} -> {:error, error}
    end
  end
end
