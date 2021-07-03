defmodule DeepThoughtWeb.EventController do
  @moduledoc """
  Controller responsible for receiving Slack events via webhook and either responding directly (in case of simple
  events such as `url_verification`), or dispatching events to appropriate background workers (in case of translation
  events).
  """

  use DeepThoughtWeb, :controller

  @doc """
  Receive a Slack event and based on pattern matching the payload, dispatch an appropriate response or action.
  """
  @spec process(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def process(conn, %{"type" => "url_verification", "challenge" => challenge}) do
    json(conn, %{challenge: challenge})
  end

  def process(conn, %{"event" => %{"type" => type} = event, "type" => "event_callback"}) do
    DeepThought.EventSupervisor.process(type, event)
    json(conn, %{})
  end

  def process(conn, _) do
    conn
    |> put_status(:bad_request)
    |> json(%{})
  end
end
