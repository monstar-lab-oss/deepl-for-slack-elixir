defmodule DeepThought.Slack.User do
  @moduledoc """
  Module struct for representing the database-cached data of a Slack user. Not all fields are used for translation
  purposes, but they are collected for possible future analytics use.
  """
  use Ecto.Schema
  alias DeepThought.Slack.User
  import Ecto.Changeset
  import Ecto.Query

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          display_name: String.t() | nil,
          display_name_normalized: String.t() | nil,
          email: String.t() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          real_name: String.t() | nil,
          real_name_normalized: String.t() | nil,
          user_id: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }
  schema "slack_users" do
    field :display_name, :string
    field :display_name_normalized, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :real_name, :string
    field :real_name_normalized, :string
    field :user_id, :string

    timestamps()
  end

  @doc """
  Given a Slack user, return a user-friendly username of that user. Prefers real name over display name.
  """
  @spec display_name(User.t()) :: String.t()
  def display_name(%{real_name: real_name}) when real_name != nil, do: real_name
  def display_name(%{display_name: display_name}) when display_name != nil, do: display_name
  def display_name(_), do: "unknown user"

  @doc """
  Given a list of Slack user IDs, find all matching cached users and return their profile information.
  """
  @spec find_by_user_ids([String.t()]) :: Ecto.Query.t()
  def find_by_user_ids(user_ids),
    do:
      from(u in User, where: u.user_id in ^user_ids and u.updated_at >= ^half_day_ago(), select: u)

  @doc """
  Changeset for upserting users based on data obtained from Slack API.
  """
  @spec changeset(User.t(), map()) :: Ecto.Changeset.t()
  def changeset(user, attrs),
    do:
      user
      |> cast(attrs, [
        :user_id,
        :email,
        :real_name,
        :real_name_normalized,
        :display_name,
        :display_name_normalized,
        :last_name,
        :first_name
      ])
      |> validate_required([:user_id])
      |> unique_constraint([:user_id])

  @spec half_day_ago() :: NaiveDateTime.t()
  defp half_day_ago, do: NaiveDateTime.utc_now() |> NaiveDateTime.add(-12 * 60 * 60)
end
