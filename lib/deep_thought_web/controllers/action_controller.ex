defmodule DeepThoughtWeb.ActionController do
  @moduledoc """
  Controller responsible for receiving notifications whenever users perform an action on Slack, such as selecting an
  option in a message accessory dropdown.
  """

  use DeepThoughtWeb, :controller

  @doc """
  Receive a Slack action notification and based on the action type, dispatch to the appropriate handler.
  """
  @spec process(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def process(conn, %{"payload" => params}) do
    case Jason.decode(params) do
      {:ok, %{"actions" => actions, "type" => "block_actions"} = payload} ->
        Enum.each(actions, fn action ->
          DeepThought.ActionSupervisor.process(action, payload)
        end)

      _ ->
        nil
    end

    json(conn, %{})
  end
end
