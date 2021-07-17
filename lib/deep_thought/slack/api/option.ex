defmodule DeepThought.Slack.API.Option do
  @moduledoc """
  Module struct for representing an option, which can be used for example in an overflow menu accessory.
  """

  alias DeepThought.Slack.API.{Option, Text}

  @derive {Jason.Encoder, only: [:text, :value]}
  @type t :: %__MODULE__{
          text: Text.t() | nil,
          value: String.t() | nil
        }
  defstruct text: nil, value: nil

  @doc """
  Create a new option, initializing it with text object for visual representation, and a value for identification
  purposes.
  """
  @spec new(Text.t(), String.t()) :: Option.t()
  def new(text, value), do: %Option{text: text, value: value}
end
