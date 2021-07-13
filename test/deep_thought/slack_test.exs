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
