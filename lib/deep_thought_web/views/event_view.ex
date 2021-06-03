defmodule DeepThoughtWeb.EventView do
  use DeepThoughtWeb, :view

  def render("show.json", %{event: event}) do
    %{challenge: event.challenge}
  end
end
