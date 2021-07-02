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
       |> Plug.Conn.put_private(:raw_body, body)}
  end

  test "init/1 stores the signing secret" do
    assert "secret" == VerifySignature.init("secret")
  end
end
