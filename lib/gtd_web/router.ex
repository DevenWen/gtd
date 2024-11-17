defmodule GtdWeb.Router do
  use GtdWeb, :router

  import GtdWeb.UserAuth
  alias OpenApiSpex.Plug.{RenderSpec, SwaggerUI}

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GtdWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: GtdWeb.ApiSpec
  end

  pipeline :api_auth do
    plug :fetch_api_user
  end

  scope "/", GtdWeb do
    pipe_through :browser

    get "/oauth/callbacks/:provider", UserSessionController, :new

    get "/", PageController, :home
  end

  scope "/api" do
    pipe_through :api
    get "/openapi", RenderSpec, []
    get "/swaggerui", SwaggerUI, path: "/api/openapi"
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:gtd, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GtdWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", GtdWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{GtdWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/log_in", UserLoginLive, :new
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", GtdWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/:username", UserController, :show

    live_session :require_authenticated_user,
      on_mount: [{GtdWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", GtdWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end
end
