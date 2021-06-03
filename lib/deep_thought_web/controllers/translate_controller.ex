defmodule DeepThoughtWeb.TranslateController do
  use DeepThoughtWeb, :controller

  action_fallback(DeepThoughtWeb.FallbackController)

  def create(conn, %{"channel_id" => channel_id, "text" => text, "user_name" => username}) do
    DeepThought.TranslatorSupervisor.simple_translate(channel_id, text, username)

    send_resp(conn, :ok, "")
  end
end
