defmodule DeepThought.Repo.Migrations.CreateTranslations do
  use Ecto.Migration

  def change do
    create table(:translations) do
      add :user_id, :string
      add :channel_id, :string
      add :message_ts, :string
      add :target_language, :string
      add :status, :string

      timestamps()
    end
  end
end
