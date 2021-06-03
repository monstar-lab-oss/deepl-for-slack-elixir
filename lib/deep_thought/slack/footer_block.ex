defmodule DeepThought.Slack.FooterBlock do
  alias DeepThought.Slack

  def generate(%{"ts" => message_ts, "user" => user_id}, channel_id, original_text) do
    abbreviated_text(original_text)
    |> append_username(user_id)
    |> append_permalink(channel_id, message_ts)
    |> block_content()
  end

  defp abbreviated_text(original_text) do
    case String.length(original_text) do
      x when x in 0..49 -> original_text
      _ -> String.slice(original_text, 0..48) <> "…"
    end
  end

  defp append_username(footer_text, user_id) do
    case Slack.API.users_profile_get(user_id) do
      {:ok, %{"real_name" => real_name}} ->
        footer_text <> "\nOriginally sent by: " <> real_name

      _ ->
        footer_text
    end
  end

  defp append_permalink(footer_text, channel_id, message_ts) do
    case Slack.API.chat_get_permalink(channel_id, message_ts) do
      {:ok, permalink} -> footer_text <> " (<" <> permalink <> "|permalink>)"
      _ -> footer_text
    end
  end

  defp block_content(footer_text) do
    %{
      "type" => "context",
      "elements" => [
        %{
          "type" => "mrkdwn",
          "text" => footer_text
        }
      ]
    }
  end
end
