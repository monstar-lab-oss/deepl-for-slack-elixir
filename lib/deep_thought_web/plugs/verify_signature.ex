defmodule DeepThoughtWeb.Plugs.VerifySignature do
  @moduledoc """
  Plug module responsible for terminating execution on requests that fail to provide a valid Slack signature. Requests
  like that are either a sign of application misconfiguration (in better case) or malicious attack attempt (in worse case).
  """

  import DeepThoughtWeb.CacheBodyReader
  import Plug.Conn

  @spec init(Plug.opts()) :: Plug.opts()
  def init(opts), do: opts

  @doc """
  Given an incoming connection, calculate the request’s signature (from the request’s raw body)
  and terminate the request if the expected signature from environment variable Slack signing secret
  doesn’t match the computed signature.
  """
  @spec call(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def call(conn, _opts) do
    with [timestamp] <- get_req_header(conn, "x-slack-request-timestamp"),
         [signature] <- get_req_header(conn, "x-slack-signature"),
         expected when signature == "v0=" <> expected <-
           read_cached_body(conn)
           |> sig_base_string(timestamp)
           |> calculate_digest() do
      conn
    else
      _ ->
        conn
        |> halt()
        |> send_resp(:unauthorized, "")
    end
  end

  @spec sig_base_string(String.t(), String.t()) :: String.t()
  defp sig_base_string(body, timestamp), do: "v0:" <> timestamp <> ":" <> body

  @spec signing_secret() :: String.t()
  defp signing_secret, do: Application.get_env(:deep_thought, :slack)[:signing_secret]

  @spec calculate_digest(String.t()) :: String.t()
  defp calculate_digest(text),
    do:
      :crypto.mac(:hmac, :sha256, signing_secret(), text)
      |> Base.encode16(case: :lower)
end
