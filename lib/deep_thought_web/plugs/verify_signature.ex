defmodule DeepThoughtWeb.Plugs.VerifySignature do
  @moduledoc """
  Plug module responsible for terminating execution on requests that fail to provide a valid Slack signature. Requests
  like that are either a sign of application misconfiguration (in better case) or malicious attack attempt (in worse case).
  """

  import DeepThoughtWeb.CacheBodyReader
  import Plug.Conn

  @doc """
  Initialize the plug with a Slack signing secret that will be used to compute the expected signature.
  """
  @spec init(String.t()) :: String.t()
  def init(signing_secret), do: signing_secret

  @doc """
  Given an incoming connection and a previously configured Slack signing secret, calculate the request’s signature (from
  the request’s raw body) and terminate the request if the expected signature doesn’t match the computed signature.
  """
  @spec call(Plug.Conn.t(), String.t()) :: Plug.Conn.t()
  def call(conn, signing_secret) do
    with [timestamp] <- get_req_header(conn, "x-slack-request-timestamp"),
         [signature] <- get_req_header(conn, "x-slack-signature"),
         expected when signature == "v0=" <> expected <-
           read_cached_body(conn)
           |> sig_base_string(timestamp)
           |> calculate_digest(signing_secret) do
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

  @spec calculate_digest(String.t(), String.t()) :: String.t()
  defp calculate_digest(text, signing_secret),
    do:
      :crypto.mac(:hmac, :sha256, signing_secret, text)
      |> Base.encode16(case: :lower)
end
