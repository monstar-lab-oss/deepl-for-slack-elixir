defmodule DeepThoughtWeb.ActionController do
  use DeepThoughtWeb, :controller

  action_fallback(DeepThoughtWeb.FallbackController)

  def create(conn, %{"payload" => payload}) do
    DeepThought.TranslatorSupervisor.delete(payload)

    send_resp(conn, :ok, "")
  end
end
