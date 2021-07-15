defmodule DeepThought.Slack.API.SectionBlock do
  @moduledoc """
  Struct used to represent a Slack Block of a Section type. Can be attached to a message.
  """

  alias DeepThought.Slack.API.{SectionBlock, Text}

  @derive {Jason.Encoder, only: [:type, :text]}
  @type t :: %__MODULE__{
          type: String.t(),
          text: Text.t() | nil
        }
  defstruct type: "section", text: nil

  @doc """
  Create a new empty Section Block.
  """
  @spec new() :: SectionBlock.t()
  def new, do: %SectionBlock{}

  @doc """
  Take an existing Section Block and return a new one with modified text.
  """
  @spec with_text(SectionBlock.t(), Text.t()) :: SectionBlock.t()
  def with_text(block, text), do: %SectionBlock{block | text: text}
end
