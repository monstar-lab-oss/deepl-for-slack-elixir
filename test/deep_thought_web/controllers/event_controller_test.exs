defmodule DeepThoughtWeb.EventControllerTest do
  @moduledoc """
  Test suite for the EventController’s ability to receive Slack events.
  """

  use DeepThoughtWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  @challenge "igUYoqfhIDfhfkRNJ7aaNm6YuaVjTyzxE2gKhmWW5CKJjo5S7MTw"
  @url_verification %{
    "token" => "JaDHzbfk7LgLAoMMPTEVlyWO",
    "challenge" => @challenge,
    "type" => "url_verification"
  }
  @reaction_added %{
    "event" => %{
      "reaction" => "flag-cz",
      "type" => "reaction_added"
    },
    "type" => "event_callback"
  }

  test "responds to an url_verification payload with expected challenge", %{conn: conn} do
    conn = post(conn, Routes.event_path(conn, :process), @url_verification)

    assert %{"challenge" => @challenge} = json_response(conn, 200)
  end

  test "responds immediately to a reaction_added payload", %{conn: conn} do
    conn = post(conn, Routes.event_path(conn, :process), @reaction_added)

    assert %{} = json_response(conn, 200)
  end

  test "returns status code 400 on unsupported event type", %{conn: conn} do
    conn = post(conn, Routes.event_path(conn, :process), Map.delete(@reaction_added, "type"))

    assert json_response(conn, 400)

    conn =
      post(
        conn,
        Routes.event_path(conn, :process),
        pop_in(@reaction_added["event"]["type"]) |> elem(1)
      )

    assert json_response(conn, 400)
  end
end
