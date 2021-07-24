defmodule DeepThought.Slack.API.Message do
  @moduledoc """
  Struct used to represent a message to be sent through Slack API.
  """

  alias DeepThought.Slack
  alias DeepThought.Slack.{API, User}
  alias DeepThought.Slack.API.Message

  @derive {Jason.Encoder, only: [:channel, :text, :blocks, :thread_ts, :user]}
  @type t :: %__MODULE__{
          channel: String.t(),
          text: String.t(),
          blocks: [any()],
          thread_ts: String.t() | nil,
          user: String.t() | nil,
          usernames: map()
        }
  defstruct channel: nil, text: nil, blocks: [], thread_ts: nil, user: nil, usernames: %{}

  @doc """
  Create a message struct, initializing the required fields.
  """
  @spec new(String.t(), String.t()) :: Message.t()
  def new(text, channel_id), do: %Message{channel: channel_id, text: text}

  @doc """
  Take an existing message struct and make it a reply in a thread by supplying a `thread_ts` value.
  """
  @spec in_thread(Message.t(), String.t()) :: Message.t()
  def in_thread(message, thread_ts), do: %Message{message | thread_ts: thread_ts}

  @doc """
  Take an existing message and make it targetted to a specific user by supplying a `user` value. Only for ephemeral
  messages.
  """
  @spec for_user(Message.t(), String.t()) :: Message.t()
  def for_user(message, user_id), do: %Message{message | user: user_id}

  @doc """
  Add a Slack Block to the message.
  """
  @spec add_block(Message.t(), any()) :: Message.t()
  def add_block(message, block), do: %Message{message | blocks: message.blocks ++ [block]}

  @doc """
  Take a message ready for sending to Slack API and unescape all text that might’ve been previously escaped in order to
  survive the translation process.
  """
  @spec unescape(Message.t()) :: Message.t()
  def unescape(message),
    do:
      message
      |> unescape_emojis()
      |> unescape_channels()
      |> unescape_links()
      |> unescape_usernames()
      |> unescape_code()

  @spec unescape_emojis(Message.t()) :: Message.t()
  defp unescape_emojis(%{text: text} = message),
    do: %Message{message | text: Regex.replace(~r/<\/?e>/ui, text, "")}

  @spec unescape_channels(Message.t()) :: Message.t()
  defp unescape_channels(%{text: text} = message),
    do: %Message{
      message
      | text:
          Regex.replace(~r/<c>(#C\w+)<\/c>/ui, text, fn _, channel_id ->
            "<" <> channel_id <> ">"
          end)
    }

  @spec unescape_links(Message.t()) :: Message.t()
  defp unescape_links(%{text: text} = message),
    do: %Message{
      message
      | text:
          Regex.replace(~r/<l>(.+?)<\/l>/ui, text, fn _, link ->
            "<" <> link <> ">"
          end)
    }

  @spec unescape_usernames(Message.t()) :: Message.t()
  def unescape_usernames(message),
    do:
      message
      |> collect_user_ids
      |> fetch_cached_usernames
      |> fetch_remaining_usernames
      |> replace_usernames

  @spec unescape_code(Message.t()) :: Message.t()
  def unescape_code(%{text: text} = message),
    do: %Message{
      message
      | text:
          Regex.replace(~r/(?<=(\s))?<d>(.+?)<\/d>(?=([\s,$]?))/mui, text, fn
            _, prev_char, code, next_char ->
              surround(code, prev_char, next_char)
          end)
    }

  @spec collect_user_ids(Message.t()) :: Message.t()
  defp collect_user_ids(%{text: text} = message),
    do: %Message{
      message
      | usernames:
          Regex.scan(~r/<u>@([UW]\w+?)<\/u>/ui, text, capture: :all_but_first)
          |> List.flatten()
          |> Enum.into(%{}, fn user_id -> {user_id, nil} end)
    }

  @spec fetch_cached_usernames(Message.t()) :: Message.t()
  defp fetch_cached_usernames(%{usernames: usernames} = message),
    do: %Message{
      message
      | usernames:
          Map.keys(usernames)
          |> Slack.find_users_by_user_ids()
          |> Enum.into(%{}, fn user -> {user.user_id, User.display_name(user)} end)
          |> Map.merge(usernames, fn _k, cached, _unresolved -> cached end)
    }

  @spec fetch_remaining_usernames(Message.t()) :: Message.t()
  defp fetch_remaining_usernames(%{usernames: usernames} = message),
    do: %Message{
      message
      | usernames:
          usernames
          |> Enum.filter(fn {_user_id, username} -> username == nil end)
          |> Task.async_stream(
            fn {user_id, _username} ->
              {:ok, profile} = API.users_profile_get(user_id)
              {user_id, profile}
            end,
            max_concurrency: 5
          )
          |> Enum.reduce([], fn {:ok, {user_id, profile}}, acc ->
            [Map.put(profile, "user_id", user_id) | acc]
          end)
          |> Slack.update_users!()
          |> Enum.into(%{}, fn user -> {user.user_id, User.display_name(user)} end)
          |> Map.merge(usernames, fn _k, resolved, cached -> cached || resolved end)
    }

  @spec replace_usernames(Message.t()) :: Message.t()
  defp replace_usernames(%{text: text, usernames: usernames} = message),
    do: %Message{
      message
      | text:
          Regex.replace(~r/(?<=(\s))?<u>@([UW]\w+?)<\/u>(?=([\s,$]?))/ui, text, fn
            _, prev_char, user_id, next_char ->
              "_@#{usernames[user_id]}_"
              |> surround(prev_char, next_char)
          end)
    }

  @spec surround(String.t(), String.t(), String.t()) :: String.t()
  defp surround(text, "", ""), do: " " <> text <> " "
  defp surround(text, "", _next), do: " " <> text
  defp surround(text, _prev, ""), do: text <> " "
  defp surround(text, _prev, _next), do: text
end
