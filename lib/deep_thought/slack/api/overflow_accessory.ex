defmodule DeepThought.Slack.API.OverflowAccessory do
  @moduledoc """
  Struct module for representing the Overflow Accessory that can be appended to a block.
  """

  alias DeepThought.Slack.API.{Confirm, Option, OverflowAccessory}

  @derive {Jason.Encoder, only: [:type, :action_id, :options, :confirm]}
  @type t :: %__MODULE__{
          type: String.t(),
          action_id: String.t() | nil,
          options: [Option.t()],
          confirm: [Confirm.t()]
        }
  defstruct type: "overflow", action_id: nil, options: [], confirm: []

  @doc """
  Create a new accessory of Overflow type.
  """
  @spec new(Option.t() | [Option.t()], Confirm.t(), String.t()) :: OverflowAccessory.t()
  def new(options, confirm, action_id) when is_list(options),
    do: %OverflowAccessory{action_id: action_id, options: options, confirm: confirm}

  def new(option, confirm, action_id),
    do: OverflowAccessory.new([option], confirm, action_id)
end
