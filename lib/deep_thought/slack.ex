defmodule DeepThought.Slack do
  @moduledoc """
  The Slack context.
  """

  import Ecto.Query, warn: false
  alias DeepThought.Repo

  alias DeepThought.Slack.{Event, User}

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Repo.all(Event)
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  def recently_translated?(channel_id, message_ts, target_language) do
    count =
      Event.recently_translated(channel_id, message_ts, target_language)
      |> Ecto.Query.select([q], count(q.id))
      |> Repo.one()

    count > 0
  end

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(%{"type" => "url_verification"} = attrs) do
    %Event{}
    |> Event.url_verification_changeset(attrs)
    |> Repo.insert()
  end

  def create_event(%{"type" => "reaction_added"} = attrs) do
    %Event{}
    |> Event.reaction_added_changeset(attrs)
    |> Repo.insert()
  end

  def find_users(user_ids) do
    User.with_user_ids(user_ids)
    |> Repo.all()
  end

  def upsert_users(data) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    data =
      data
      |> Enum.map(fn row ->
        row
        |> Map.put(:inserted_at, now)
        |> Map.put(:updated_at, now)
      end)

    Repo.insert_all(User, data,
      conflict_target: [:user_id],
      on_conflict: {:replace, [:real_name, :updated_at]}
    )
  end
end
