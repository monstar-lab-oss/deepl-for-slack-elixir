defmodule DeepThoughtWeb.PageController do
  use DeepThoughtWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
