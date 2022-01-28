defmodule DeepThoughtWeb.Plugs.VerifySignatureTest do
  @moduledoc """
  Test suite for the signature verification module which is used to verify that the incoming requests originated within
  the Slack network, as opposed to fake requests by a potential attacker.
  """

  use ExUnit.Case, async: true
  use Plug.Test

  alias DeepThoughtWeb.Plugs.VerifySignature

  setup do
    body = "{}"

    {:ok,
     conn:
       conn(:post, "/slack/events", body)
       |> Plug.Conn.put_private(:raw_body, body)
       |> put_req_header("x-slack-request-timestamp", "1625202589")}
  end

  test "request with valid signature is not halted", %{conn: conn} do
    conn =
      conn
      |> put_req_header(
        "x-slack-signature",
        "v0=27ab08e51bb55b93f4cb2c749193ed0ea90986020a8fe2f0aa3972d480b9a715"
      )
      |> VerifySignature.call(nil)

    refute conn.halted
  end

  test "request with an invalid signature is halted", %{conn: conn} do
    conn =
      conn
      |> put_req_header("x-slack-signature", "invalid")
      |> VerifySignature.call(nil)

    assert conn.status == 401
    assert conn.halted
  end

  test "request with a missing signature is halted", %{conn: conn} do
    conn = VerifySignature.call(conn, nil)

    assert conn.status == 401
    assert conn.halted
  end
end
