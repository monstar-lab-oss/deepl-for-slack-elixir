defmodule DeepThought.Slack.Handler.Delete do
  @moduledoc """
  Module responsible for handling the `delete` option from the `overflow_delete` Slack Action, which is triggered
  whenever a user opens the overflow menu and confirms the _Delete Translation_ option. We need to delete the
  translation from the thread and respond to the user via an ephemeral message.
  """

  @doc """
  """
  @spec(delete_message(map(), map()) :: :ok, {:error, atom()})
  def delete_message(action, context) do
    :ok
  end
end
