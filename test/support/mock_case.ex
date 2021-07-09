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

  setup do
    Tesla.Mock.mock(fn
      %{url: "https://api.deepl.com/" <> _rest} -> setup_deepl()
      %{url: "https://slack.com/api" <> method} -> setup_slack(method)
    end)

    :ok
  end

  def setup_deepl, do: json(%{"translations" => [%{"text" => "Ahoj, světe!"}]})

  def setup_slack(method) do
    case method do
      "/chat.postMessage" -> json(%{})
      "/conversations.replies" -> json(%{"messages" => [%{"text" => "Hello, world!", "ts" => "1625806692.000500"}]})
    end
  end
end
