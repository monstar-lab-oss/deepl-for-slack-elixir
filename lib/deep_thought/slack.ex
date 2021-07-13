defmodule DeepThought.Slack do
  @moduledoc """
  The Slack context.
  """

  import Ecto.Query, warn: false
  alias DeepThought.Repo

  alias DeepThought.Slack.User

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
      |> Enum.reverse()
    end)
  end
end
