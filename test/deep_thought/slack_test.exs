defmodule DeepThought.SlackTest do
  @moduledoc """
  Test suite for database operations on Slack users.
  """

  use DeepThought.DataCase
  alias DeepThought.Slack

  describe "users" do
    alias DeepThought.Slack.User

    @user1 %{
      display_name: "display_name",
      real_name: "real_name",
      user_id: "U123456"
    }
    @user2 %{
      display_name: "name_display",
      real_name: "name_real",
      user_id: "U987654"
    }

    test "find_users_by_user_ids/1 finds user accounts" do
      assert [%User{}, %User{}] = Slack.update_users!([@user1, @user2])
      assert [user1, user2] = Slack.find_users_by_user_ids(~w[U123456 U987654])
      assert user1.user_id == "U123456"
      assert user2.user_id == "U987654"
    end

    test "find_users_by_user_ids/1 doesn’t return stale data" do
      today = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      yesterday = today |> NaiveDateTime.add(-24 * 60 * 60)

      DeepThought.Repo.transaction(fn ->
        DeepThought.Repo.insert_all(Slack.User, [
          Map.merge(@user1, %{inserted_at: yesterday, updated_at: yesterday}),
          Map.merge(@user2, %{inserted_at: today, updated_at: today})
        ])

        assert [user] = result = Slack.find_users_by_user_ids(~w[U123456 U987654])
        assert user.user_id == "U987654"
        assert Enum.count(result) == 1

        Repo.rollback(:cleanup)
      end)
    end

    test "update_users/1 with valid data creates/updates users" do
      assert [%User{} = user1, %User{} = user2] = Slack.update_users!([@user1, @user2])
      assert user1.display_name == "display_name"
      assert user1.real_name == "real_name"
      assert user1.user_id == "U123456"
      assert user2.display_name == "name_display"
      assert user2.real_name == "name_real"
      assert user2.user_id == "U987654"
    end
  end
end
