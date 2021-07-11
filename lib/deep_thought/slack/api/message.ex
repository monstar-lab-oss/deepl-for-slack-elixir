defmodule DeepThought.Slack.API.Message do
  @moduledoc """
  Struct used to represent a message to be sent through Slack API.
  """

  alias DeepThought.Slack.API.Message

  @derive {Jason.Encoder, only: [:channel, :text, :thread_ts]}
  @type t :: %__MODULE__{
          channel: String.t(),
          text: String.t(),
          thread_ts: String.t() | nil
        }
  defstruct channel: nil, text: nil, thread_ts: nil

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
  Take a message ready for sending to Slack API and unescape all text that might’ve been previously escaped in order to
  survive the translation process.
  """
  @spec unescape(Message.t()) :: Message.t()
  def unescape(message),
    do:
      message
      |> unescape_emojis
      |> unescape_channels

  @spec unescape_emojis(Message.t()) :: Message.t()
  defp unescape_emojis(%{text: text} = message),
    do: %Message{message | text: Regex.replace(~r/<\/?emoji>/ui, text, "")}

  @spec unescape_channels(Message.t()) :: Message.t()
  def unescape_channels(%{text: text} = message),
    do: %Message{
      message
      | text:
          Regex.replace(~r/<channel>(#C\w+)<\/channel>/ui, text, fn _, channel_id ->
            "<" <> channel_id <> ">"
          end)
    }
end
