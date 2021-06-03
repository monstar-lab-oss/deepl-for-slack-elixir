defmodule DeepThought.Repo.Migrations.AddReactionRelatedFieldsToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add(:target_language, :string)
      add(:channel_id, :string)
      add(:message_ts, :string)
    end
  end
end
