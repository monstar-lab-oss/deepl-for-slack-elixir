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

  describe "translations" do
    alias DeepThought.Slack.Translation

    @valid_attrs %{
      channel_id: "C12345",
      message_ts: "12345.000",
      status: "success",
      target_language: "JA",
      user_id: "U12345"
    }
    @invalid_attrs %{
      channel_id: nil,
      message_ts: nil,
      status: nil,
      target_language: nil,
      user_id: nil
    }

    def translation_fixture(attrs \\ %{}) do
      {:ok, translation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Slack.create_translation()

      translation
    end

    test "recently_translated?/3 can find a recently translated message" do
      %{channel_id: channel_id, message_ts: message_ts, target_language: target_language} =
        @valid_attrs

      assert false == Slack.recently_translated?(channel_id, message_ts, target_language)
      assert {:ok, %Translation{}} = Slack.create_translation(@valid_attrs)
      assert true == Slack.recently_translated?(channel_id, message_ts, target_language)
    end

    test "create_translation/1 with valid data creates a translation" do
      assert {:ok, %Translation{} = translation} = Slack.create_translation(@valid_attrs)
      assert translation.channel_id == "C12345"
      assert translation.message_ts == "12345.000"
      assert translation.status == "success"
      assert translation.target_language == "JA"
      assert translation.user_id == "U12345"
    end

    test "create_translation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Slack.create_translation(@invalid_attrs)
    end
  end
end
