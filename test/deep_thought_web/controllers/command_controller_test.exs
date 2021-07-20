defmodule DeepThoughtWeb.CommandControllerTest do
  @moduledoc """
  Test suite for the CommandController’s ability to handle commands.
  """

  use DeepThoughtWeb.ConnCase

  test "immediately returns usage instructions when no text is provided", %{conn: conn} do
    conn =
      post(conn, Routes.command_path(conn, :process), %{"command" => "/translate", "text" => ""})

    assert conn.resp_body =~ "Here’s an example"
  end

  test "returns status code 400 on unsupported command", %{conn: conn} do
    conn = post(conn, Routes.command_path(conn, :process), %{"command" => "/make-coffee"})

    assert conn.status == 400
  end
end
