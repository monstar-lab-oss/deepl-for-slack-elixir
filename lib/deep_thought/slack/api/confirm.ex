defmodule DeepThought.Slack.API.Confirm do
  @moduledoc """
  Struct module for representing a Confirm object.
  """

  alias DeepThought.Slack.API.{Confirm, Text}

  @derive {Jason.Encoder, only: [:title, :text, :confirm, :deny]}
  @type t :: %__MODULE__{
          title: Text.t() | nil,
          text: Text.t() | nil,
          confirm: Text.t() | nil,
          deny: Text.t() | nil
        }
  defstruct title: nil, text: nil, confirm: nil, deny: nil

  @doc """
  Creates a new empty Confirm object.
  """
  @spec new(Text.t(), Text.t(), Text.t(), Text.t()) :: Confirm.t()
  def new(title, text, confirm, deny),
    do: %Confirm{title: title, text: text, confirm: confirm, deny: deny}

  @doc """
  Created a new Confirm object with default values.
  """
  @spec default() :: Confirm.t()
  def default,
    do:
      Confirm.new(
        Text.new("Are you sure?", "plain_text"),
        Text.new("Are you sure you want to proceed?"),
        Text.new("Yes, proceed", "plain_text"),
        Text.new("No, I changed my mind", "plain_text")
      )
end
