defmodule DeepThought.Slack do
  @moduledoc """
  The Slack context.
  """

  import Ecto.Query, warn: false
  alias DeepThought.Repo

  alias DeepThought.Slack.User

  @doc """
  Find users by user_ids.
  """
  @spec find_users_by_user_ids([String.t()]) :: [User.t()]
  def find_users_by_user_ids(user_ids) do
    User.find_by_user_ids(user_ids)
    |> Repo.all()
  end

  @doc """
  Inserts or updates user information in database.
  """
  @spec update_users!([map()]) :: [User.t()]
  def update_users!(users) do
    users
    |> Stream.map(fn user -> User.changeset(%User{}, user) end)
    |> Enum.reduce([], fn changeset, acc ->
      [
        Repo.insert!(changeset,
          returning: true,
          conflict_target: :user_id,
          on_conflict: {:replace_all_except, [:id, :user_id]}
        )
        | acc
      ]
    end)
    |> Enum.reverse()
  end
end
