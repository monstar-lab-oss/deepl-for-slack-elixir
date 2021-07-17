defmodule DeepThought.Slack.Translation do
  @moduledoc """
  Module struct for representing translation requests, whether they were successful or not.
  """
  use Ecto.Schema
  alias DeepThought.Slack.Translation
  import Ecto.Changeset
  import Ecto.Query

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          channel_id: String.t() | nil,
          message_ts: String.t() | nil,
          status: String.t() | nil,
          target_language: String.t() | nil,
          translation_channel_id: String.t() | nil,
          translation_message_ts: String.t() | nil,
          user_id: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }
  @type r :: {:ok, Translation.t()} | {:error, Ecto.Changeset.t()}
  schema "translations" do
    field :channel_id, :string
    field :message_ts, :string
    field :status, :string
    field :target_language, :string
    field :translation_channel_id, :string
    field :translation_message_ts, :string
    field :user_id, :string

    timestamps()
  end

  @doc """
  Given information about message about to be translated, returns information whether this message was recently
  translated into the same language.
  """
  @spec recently_translated?(String.t(), String.t(), String.t()) :: Ecto.Query.t()
  def recently_translated?(channel_id, message_ts, target_language),
    do:
      from(t in Translation,
        where:
          t.channel_id == ^channel_id and
            t.message_ts == ^message_ts and
            t.target_language == ^target_language and
            t.status == "success" and
            t.inserted_at >= ^one_day_ago()
      )

  @spec one_day_ago() :: NaiveDateTime.t()
  defp one_day_ago, do: NaiveDateTime.utc_now() |> NaiveDateTime.add(-24 * 60 * 60)

  @doc """
  Changeset for creating a new translation request record.
  """
  @spec changeset(Translation.t(), map()) :: Ecto.Changeset.t()
  def changeset(translation, attrs) do
    translation
    |> cast(attrs, [
      :user_id,
      :channel_id,
      :message_ts,
      :target_language,
      :status,
      :translation_channel_id,
      :translation_message_ts
    ])
    |> validate_required([:user_id, :channel_id, :message_ts, :target_language, :status])
  end
end
