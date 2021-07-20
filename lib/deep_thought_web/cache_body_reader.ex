defmodule DeepThoughtWeb.CacheBodyReader do
  @moduledoc """
  Helper module that stores the raw, unparsed request body in the `Plug.Conn` for later use. This is required, for
  example, if you need to compute a signature from the unparsed request body in order to validate that the request comes
  from a trusted source.
  """

  @doc """
  Given a connection, will read the connection’s raw body value and store it under the `:raw_body` key where
  `read_cached_body/1` function can fetch it later.
  """
  @spec read_body(Plug.Conn.t(), Keyword.t()) :: {:ok, any(), Plug.Conn.t()}
  def read_body(conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    conn = Plug.Conn.put_private(conn, :raw_body, body)

    {:ok, body, conn}
  end

  @doc """
  Given a connection that was previously inspected with `read_body/2`, returns the raw unparsed request body.
  """
  @spec read_cached_body(Plug.Conn.t()) :: String.t()
  def read_cached_body(conn), do: conn.private[:raw_body]
end
