defmodule DeepThought.Slack.TranslationBlock do
  def generate(translated_text) do
    block_content(translated_text)
  end

  defp block_content(translated_text) do
    %{
      "type" => "section",
      "text" => %{
        "type" => "mrkdwn",
        "text" => translated_text
      },
      "accessory" => accessory_content()
    }
  end

  defp accessory_content do
    %{
      "type" => "overflow",
      "confirm" => %{
        "title" => confirm_title(),
        "text" => confirm_text(),
        "confirm" => confirm_button(),
        "deny" => deny_button()
      },
      "options" => accessory_options(),
      "action_id" => "overflow"
    }
  end

  defp confirm_title, do: %{"type" => "plain_text", "text" => "Are you sure?"}

  defp confirm_text,
    do: %{"type" => "mrkdwn", "text" => "Are you sure you want to delete this translation? 🗑️"}

  defp confirm_button, do: %{"type" => "plain_text", "text" => "Do it!"}
  defp deny_button, do: %{"type" => "plain_text", "text" => "Stop, I changed my mind!"}

  defp accessory_options,
    do: [
      %{
        "text" => %{
          "type" => "plain_text",
          "text" => "Delete this translation"
        },
        "value" => "delete"
      }
    ]
end
