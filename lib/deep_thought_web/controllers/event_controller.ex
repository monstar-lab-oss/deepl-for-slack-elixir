defmodule DeepThoughtWeb.EventController do
  use DeepThoughtWeb, :controller

  alias DeepThought.Slack
  alias DeepThought.Slack.Event

  action_fallback(DeepThoughtWeb.FallbackController)

  def create(conn, %{"type" => "url_verification"} = event_params) do
    with {:ok, %Event{} = event} <- Slack.create_event(event_params) do
      render(conn, "show.json", event: event)
    end
  end

  def create(
        conn,
        %{
          "event" =>
            %{
              "item" => %{"channel" => channel_id, "ts" => message_ts, "type" => "message"},
              "reaction" => reaction,
              "type" => "reaction_added"
            } = event_details,
          "type" => "event_callback"
        }
      ) do
    DeepThought.TranslatorSupervisor.translate(event_details, reaction, channel_id, message_ts)
    send_resp(conn, :ok, "")
  end
end
