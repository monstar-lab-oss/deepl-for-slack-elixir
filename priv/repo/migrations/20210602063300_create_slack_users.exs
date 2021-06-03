defmodule DeepThought.Repo.Migrations.CreateSlackUsers do
  use Ecto.Migration

  def change do
    create table(:slack_users) do
      add(:user_id, :string, null: false)
      add(:real_name, :string, null: false)

      timestamps()
    end

    create(unique_index(:slack_users, [:user_id]))
  end
end
