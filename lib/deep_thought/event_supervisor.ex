defmodule DeepThought.EventSupervisor do
  @moduledoc """
  Module invoked from `DeepThought.EventController` responsible for dispatching the received event into an appropriate
  event handler function. In case the event handler dies, a certain number of restarts is attempted before giving up.
  """

  @opts [restart: :transient]

  @doc """
  Determines the appropriate handler for an evetn and dispatches the event details to that particular event handler.
  """
  @spec process(String.t(), map()) :: DynamicSupervisor.on_start_child()
  def process("reaction_added", event),
    do:
      Task.Supervisor.start_child(
        __MODULE__,
        DeepThought.Slack.Handler.ReactionAdded,
        :reaction_added,
        [event],
        @opts
      )
end
