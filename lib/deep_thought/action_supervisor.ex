defmodule DeepThought.ActionSupervisor do
  @moduledoc """
  Module invoked from `DeepThought.ActionController` responsible for handling user interactions through Slack actions,
  such as clicking on button in an overflow menu or issuing a Slack command.
  """

  @opts [restart: :transient]

  @doc """
  Determines the appropriate handler for an action
  """
  @spec process(map(), map()) :: DynamicSupervisor.on_start_child()
  def process(
        %{"action_id" => "delete_overflow", "selected_option" => %{"value" => "delete"}} = action,
        context
      ),
      do:
        Task.Supervisor.start_child(
          __MODULE__,
          DeepThought.Slack.Handler.Delete,
          :delete_message,
          [action, context],
          @opts
        )
end
