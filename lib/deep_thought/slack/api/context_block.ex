defmodule DeepThought.Slack.API.ContextBlock do
  @moduledoc """
  Struct used to represent a Slack Block of a Context type. Can be attached to a message.
  """

  alias DeepThought.Slack.API.{ContextBlock, Text}

  @derive {Jason.Encoder, only: [:type, :elements]}
  @type t :: %__MODULE__{
          type: String.t(),
          elements: [Text.t()]
        }
  defstruct type: "context", elements: []

  @doc """
  Create a new empty Context Block.
  """
  @spec new() :: ContextBlock.t()
  def new, do: %ContextBlock{}

  @doc """
  Take an existing Context Block and append a new Text element to it.
  """
  @spec with_text(ContextBlock.t(), Text.t()) :: ContextBlock.t()
  def with_text(block, text), do: %ContextBlock{block | elements: [text | block.elements]}
end
