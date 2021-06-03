defmodule DeepThoughtWeb.Plugs.SignatureVerifier do
  import Plug.Conn

  def init(signing_key), do: signing_key

  def call(conn, signing_key) do
    with [timestamp] <- get_req_header(conn, "x-slack-request-timestamp"),
         [expected] <- get_req_header(conn, "x-slack-signature"),
         body <- get_cached_req_body(conn),
         sig_basestring <- get_sig_basestring(timestamp, body),
         digest <- calculate_digest(signing_key, sig_basestring),
         :ok <- verify_signature(expected, digest) do
      conn
    else
      _ ->
        conn
        |> halt()
        |> send_resp(:unauthorized, "")
    end
  end

  defp get_cached_req_body(conn), do: DeepThoughtWeb.CacheBodyReader.read_cached_body(conn)
  defp get_sig_basestring(timestamp, body), do: "v0:" <> timestamp <> ":" <> body

  defp calculate_digest(signing_key, sig_basestring) do
    :crypto.mac(:hmac, :sha256, signing_key, sig_basestring)
    |> Base.encode16(case: :lower)
  end

  defp verify_signature(expected, digest) when expected == "v0=" <> digest, do: :ok
  defp verify_signature(_, _), do: :error
end
