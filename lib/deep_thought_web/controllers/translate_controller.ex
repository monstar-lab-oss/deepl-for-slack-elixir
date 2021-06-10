defmodule DeepThoughtWeb.TranslateController do
  use DeepThoughtWeb, :controller

  action_fallback(DeepThoughtWeb.FallbackController)

  def create(conn, %{
        "channel_id" => channel_id,
        "text" => text,
        "user_name" => username,
        "user_id" => user_id
      }) do
    DeepThought.TranslatorSupervisor.simple_translate(channel_id, text, username, user_id)

    send_resp(conn, :ok, "")
  end
end
