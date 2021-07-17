defmodule DeepThought.Repo.Migrations.AddTranslationTsToTranslations do
  use Ecto.Migration

  def change do
    alter table(:translations) do
      add :translation_channel_id, :string
      add :translation_message_ts, :string
    end
  end
end
