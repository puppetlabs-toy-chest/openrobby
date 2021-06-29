defmodule RobbyWeb.Router do
  use RobbyWeb.Web, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(RobbyWeb.Plugs.Locale, "en")
    plug(RobbyWeb.Auth, repo: RobbyWeb.Repo)
  end

  pipeline :protected do
    plug(:authenticate_user)
  end

  pipeline :unauthorized do
    plug(RobbyWeb.Unauthorized)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", RobbyWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/index.html", PageController, :index)
    get("/about.html", PageController, :about)
    get("/password_hall_of_shame", PageController, :password_hall_of_shame)
    resources("/sessions", SessionController, only: [:new, :create, :delete])

    resources "/password_reset", PasswordResetController do
      resources("/2fa", SmsCodeController, only: [:index, :create])
    end
  end

  scope "/profile", RobbyWeb do
    pipe_through([:browser, :protected])
    get("/:id", ProfileController, :show)
    post("/:id/photo_complaint", ProfileController, :photo_complaint)
  end

  scope "/maps", RobbyWeb do
    pipe_through([:browser, :protected])
    get("/", MapsController, :index)
    get("/:id", MapsController, :show)
  end

  scope "/settings", RobbyWeb do
    pipe_through([:browser, :protected])
    get("/profile", SettingsProfileController, :show)
    get("/profile/edit", SettingsProfileController, :edit)
    put("/profile/update", SettingsProfileController, :update)
  end

  scope "/user", RobbyWeb do
    pipe_through([:browser, :protected])

    get("/password_change", PasswordChangeController, :index)
    post("/password_change", PasswordChangeController, :create)
  end

  scope "/chat", RobbyWeb do
    pipe_through([:browser, :protected])
    resources("/rooms", RoomController)
  end

  scope "/game", RobbyWeb do
    pipe_through([:browser, :protected])
    get("/new", NameGameController, :new)
    get("/leaderboard", NameGameController, :leaderboard)
    get("/:id", NameGameController, :show)
    put("/:id/update", NameGameController, :update)
  end

  scope "/admin", RobbyWeb do
    pipe_through([:browser, :unauthorized])

    resources("/password_policies", PasswordPolicyController)

    resources "/users", UserController do
    end
  end
end

# Other scopes may use custom stacks.
# scope "/api", RobbyWeb do
#   pipe_through :api
# end
