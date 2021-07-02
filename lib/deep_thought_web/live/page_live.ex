defmodule DeepThoughtWeb.PageLive do
  @moduledoc """
  Currently unused landing page module.
  """

  use DeepThoughtWeb, :live_view
  import Appsignal.Phoenix.LiveView, only: [instrument: 4]

  @impl true
  def mount(_params, _session, socket) do
    instrument(__MODULE__, "mount", socket, fn ->
      {:ok, assign(socket, query: "", results: %{})}
    end)
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    instrument(__MODULE__, "suggest", socket, fn ->
      {:noreply, assign(socket, results: search(query), query: query)}
    end)
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    instrument(__MODULE__, "search", socket, fn ->
      case search(query) do
        %{^query => vsn} ->
          {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

        _ ->
          {:noreply,
           socket
           |> put_flash(:error, "No dependencies found matching \"#{query}\"")
           |> assign(results: %{}, query: query)}
      end
    end)
  end

  defp search(query) do
    if not DeepThoughtWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end
end
