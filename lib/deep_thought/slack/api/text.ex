defmodule DeepThought.Slack.API.Text do
  @moduledoc """
  Struct used to represent Slack API’s Text object.
  """

  alias DeepThought.Slack.API.Text

  @derive {Jason.Encoder, only: [:type, :text]}
  @type t :: %__MODULE__{
          type: String.t(),
          text: String.t()
        }
  defstruct type: "", text: ""

  @doc """
  Create a new Text object with given text and optionally a type.
  """
  @spec new(String.t(), String.t()) :: Text.t()
  def new(text, type \\ "mrkdwn"), do: %Text{type: type, text: text}
end
