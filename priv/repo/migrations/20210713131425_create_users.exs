defmodule DeepThought.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:slack_users) do
      add :user_id, :string
      add :email, :string
      add :real_name, :string
      add :real_name_normalized, :string
      add :display_name, :string
      add :display_name_normalized, :string
      add :last_name, :string
      add :first_name, :string

      timestamps()
    end

    create unique_index(:slack_users, [:user_id])
  end
end
