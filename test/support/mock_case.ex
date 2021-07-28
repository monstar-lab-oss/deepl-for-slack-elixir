defmodule DeepThought.MockCase do
  @moduledoc """
  Module template that sets up DeepL API and Slack API client mocks.
  """

  use ExUnit.CaseTemplate
  import Tesla.Mock

  using do
    quote do
      alias DeepThought.DeepL
      alias DeepThought.Slack
    end
  end

  setup_all do
    Tesla.Mock.mock_global(fn
      %{url: "https://api.deepl.com/" <> _rest} -> setup_deepl()
      %{url: "https://slack.com/api" <> method} = env -> setup_slack(env, method)
    end)

    :ok
  end

  def setup_deepl, do: json(%{"translations" => [%{"text" => "Ahoj, světe!"}]})

  def setup_slack(env, method) do
    case method do
      "/chat.getPermalink" ->
        json(%{
          "ok" => true,
          "permalink" => "https://ghostbusters.slack.com/archives/C1H9RESGA/p135854651500008"
        })

      "/chat.postMessage" ->
        json(%{"ok" => true, "channel" => "C1H9RESGA", "ts" => "1459571776.000001"})

      "/chat." <> _rest ->
        json(%{"ok" => true})

      "/conversations.replies" ->
        json(%{
          "ok" => true,
          "messages" => [%{"text" => "Hello, world!", "ts" => "1625806692.000500"}]
        })

      "/users.profile.get" ->
        real_name =
          case env.query[:user] do
            "U9FE1J23V" -> "Milan Vít"
            "U0233M3T96K" -> "Deep Thought"
            "U0171KB36DN" -> "dokku"
          end

        json(%{"ok" => true, "profile" => %{"real_name" => real_name}})
    end
  end
end
