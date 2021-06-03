defmodule DeepThought.Repo do
  use Ecto.Repo,
    otp_app: :deep_thought,
    adapter: Ecto.Adapters.Postgres
end
