defmodule DeepThoughtWeb.CommandController do
  @moduledoc """
  Controller responsible for receiving Slack commands and passing them to the appropriate background worker.
  """

  use DeepThoughtWeb, :controller

  @doc """
  Receive a Slack command and based on the command name, pass it to an appropriate background worker.
  """
  @spec process(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def process(conn, %{"command" => "/translate", "text" => ""}),
    do:
      send_resp(conn, :ok, """
      To use the `/translate` command, please invoke it like so: `/translate [target language] [text to translate]`.
      Here’s an example that translates the given text from English to Japanese: `/translate 🇯🇵 Hello, world!`
      You can specify the language with an emoji flag, just like you would when using the react-to-translate feature.
      """)

  def process(conn, %{"command" => command} = params) when command in ["/translate"] do
    DeepThought.CommandSupervisor.process(command, params)
    send_resp(conn, :ok, "")
  end

  def process(conn, _params), do: send_resp(conn, :bad_request, "")
end
