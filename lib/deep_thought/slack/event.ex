defmodule DeepThought.Slack.Event do
  use Ecto.Schema

  alias DeepThought.Slack.Event
  import Ecto.Changeset
  import Ecto.Query

  schema "events" do
    field(:type, :string, null: false)
    field(:challenge, :string)
    field(:target_language, :string)
    field(:channel_id, :string)
    field(:message_ts, :string)

    timestamps()
  end

  @doc false
  def url_verification_changeset(event, attrs) do
    event
    |> cast(attrs, [:type, :challenge])
    |> validate_required([:type, :challenge])
  end

  def reaction_added_changeset(event, attrs) do
    event
    |> cast(attrs, [:type, :target_language, :channel_id, :message_ts])
    |> validate_required([:type, :target_language, :channel_id, :message_ts])
  end

  def recently_translated(channel_id, message_ts, target_language) do
    one_day_ago = NaiveDateTime.utc_now() |> NaiveDateTime.add(-60 * 60 * 24)

    from(e in Event,
      where:
        e.type == ^"reaction_added" and e.channel_id == ^channel_id and
          e.message_ts == ^message_ts and e.target_language == ^target_language and
          e.inserted_at >= ^one_day_ago
    )
  end
end
