defmodule DeepThoughtWeb.Router do
  use DeepThoughtWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {DeepThoughtWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :slack_api do
    plug(
      DeepThoughtWeb.Plugs.SignatureVerifier,
      Application.get_env(:deep_thought, :slack)[:signing_secret]
    )
  end

  scope "/slack", DeepThoughtWeb do
    pipe_through([:api, :slack_api])

    post("/actions", ActionController, :create)
    post("/commands/translate", TranslateController, :create)
    post("/events", EventController, :create)
  end

  scope "/", DeepThoughtWeb do
    pipe_through(:browser)

    live("/", PageLive, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", DeepThoughtWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: DeepThoughtWeb.Telemetry)
    end
  end
end
