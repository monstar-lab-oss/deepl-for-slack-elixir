defmodule DeepThought.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :type, :string, null: false
      add :challenge, :string

      timestamps()
    end
  end
end
