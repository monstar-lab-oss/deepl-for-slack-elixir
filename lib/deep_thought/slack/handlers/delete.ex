defmodule DeepThought.Slack.Handler.Delete do
  @moduledoc """
  Module responsible for handling the `delete` option from the `overflow_delete` Slack Action, which is triggered
  whenever a user opens the overflow menu and confirms the _Delete Translation_ option. We need to delete the
  translation from the thread and respond to the user via an ephemeral message.
  """

  alias DeepThought.Slack
  alias DeepThought.Slack.API.Message

  @doc """
  """
  @spec delete_message(map(), map()) :: :ok | {:error, atom()}
  def delete_message(_action, %{
        "container" => %{
          "channel_id" => channel_id,
          "message_ts" => message_ts,
          "thread_ts" => thread_ts
        },
        "user" => %{"id" => user_id}
      }) do
    with :ok <- Slack.API.chat_delete(channel_id, message_ts) do
      Message.new("I deleted the translation!", channel_id)
      |> Message.in_thread(thread_ts)
      |> Message.for_user(user_id)
      |> Slack.API.chat_post_ephemeral()

      :ok
    end
  end
end
