defmodule DeepThought.CommandSupervisor do
  @moduledoc """
  Module invoked from `DeepThoughtWeb.CommandController` responsible for dispatching the received event into an
  appropriate event handler function.
  """

  @opts [restart: :transient]

  @doc """
  Determines the appropriate handler for the command and dispatches the command details to a command handler.
  """
  @spec process(String.t(), map()) :: DynamicSupervisor.on_start_child() | nonempty_list()
  def process("/translate", command),
    do:
      Task.Supervisor.start_child(
        __MODULE__,
        DeepThought.Slack.Handler.Translate,
        :translate,
        [command],
        @opts
      )

  def process(_type, _command), do: nil
end
