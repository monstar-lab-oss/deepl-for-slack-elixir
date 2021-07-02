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

  test "responds to a url_verification payload", %{conn: conn} do
    conn = post(conn, Routes.event_path(conn, :process), @url_verification)

    assert %{"challenge" => @challenge} = json_response(conn, 200)
  end
end
