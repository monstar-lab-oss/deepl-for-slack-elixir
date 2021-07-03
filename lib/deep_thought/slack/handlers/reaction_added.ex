defmodule DeepThought.Slack.Handler.ReactionAdded do
  @moduledoc """
  Module responsible for handling the `reaction_added` Slack event, which is received when user adds a reaction emoji to
  a message. This might be a normal emoji, or a flag emoji, which would indicate the desire to translate the message to
  another language.
  """

  alias DeepThought.Slack.Language

  @doc """
  Take event details, interpret the details, if the event points to a translation request, fetch the message details,
  translate the message text and post the translation in thread.
  """
  @typep reason() :: :unknown_language
  @spec reaction_added(map()) :: {:ok, String.t()} | {:error, reason()}
  def reaction_added(%{"reaction" => reaction}) do
    with {:ok, language} <- Language.new(reaction) do
      IO.inspect(language)
    else
      {:error, :unknown_language} -> nil
    end
  end
end
