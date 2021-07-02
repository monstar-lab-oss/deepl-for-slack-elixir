defmodule DeepThoughtWeb.Plugs.VerifySignature do
  @moduledoc """
  Plug module responsible for terminating execution on requests that fail to provide a valid Slack signature. Requests
  like that are either a sign of application misconfiguration (in better case) or malicious attack attempt (in worse case).
  """

  @doc """
  Initialize the plug with a Slack signing secret that will be used to compute the expected signature.
  """
  @spec init(String.t()) :: String.t()
  def init(signing_secret), do: signing_secret
end
