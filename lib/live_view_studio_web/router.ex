defmodule LiveViewStudioWeb.Router do
  use LiveViewStudioWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LiveViewStudioWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveViewStudioWeb do
    pipe_through :browser

    # Controller routes
    get "/", PageController, :index

    # LiveView routes
    live "/index", IndexLive
    live "/hex-search", HexSearchLive
    live "/light", LightLive
    live "/license", LicenseLive
    live "/sales-dashboard", SalesDashboardLive
    live "/search", SearchLive
    live "/autocomolete", AutocompleteLive
    live "/filter", FilterLive
    live "/servers", ServersLive
    live "/servers/new", ServersLive, :new
    live "/paginate", PaginateLive
    live "/sort", SortLive
    live "/volunteers", VolunteersLive
    live "/inifinite-scroll", InfiniteScrollLive
    live "/datepicker", DatePickerLive
    live "/sandbox", SandboxLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveViewStudioWeb do
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
      pipe_through :browser
      live_dashboard "/dashboard", metrics: LiveViewStudioWeb.Telemetry
    end
  end
end
