defmodule RobbyWeb.SettingsProfileController do
  use RobbyWeb.Web, :controller

  alias RobbyWeb.{ErrorHandler, Profile, User, LdapRepo, PhotoHandler}
  alias Plug.Conn

  plug RobbyWeb.Plugs.LoadEmployeeIds
  plug :scrub_params, "profile" when action in [:update]
  plug :find_user when action in [:show, :edit, :update]
  plug :authenticate_user when action in [:update]
  plug :fetch_profile_from_ldap when action in [:show, :edit, :update]

  def find_user(conn, _) do
    user = Repo.get(User, conn.assigns.current_user.id)
    assign(conn, :repo_user, user)
  end

  def authenticate_user(%Conn{assigns: %{current_user: current_user}, params: %{"profile" => profile}} = conn, _opts) do
    dn = current_user.dn
    password = Map.get(profile, "password")
    case LdapSearch.authenticate(dn, password) do
      {:error, _error} ->
        conn
        |> put_flash(:error, "Authentication failed, please provide valid credentials.")
        |> assign(:auth_status, :failure)
      :ok ->
        assign(conn, :auth_status, :success)
    end
  end

  def fetch_profile_from_ldap(conn, _opts) do
    profile = LdapRepo.get(Profile, conn.assigns.repo_user.dn)
    assign(conn, :user_profile, profile)
  end

  def show(%Conn{assigns: %{repo_user: repo_user, user_profile: user_profile}} = conn, _) do
    manager = manager_for(user_profile.manager)
    reports = direct_reports_for(user_profile)
    render(conn, "show.html", title: "My Profile", user: repo_user, user_profile: user_profile, manager: manager, reports: reports)
  end

  def manager_for(manager_dn) when not is_nil(manager_dn) do
    from(u in Profile.orgPeople,
      where: u.dn == ^manager_dn,
      select: {u.uid, u.cn})
    |> LdapRepo.one
  end
  def manager_for(_), do: nil

  def direct_reports_for(profile) do
    from(u in Profile.orgPeople,
      where: u.manager == ^profile.dn,
      select: {u.uid, u.cn})
    |> LdapRepo.all
  end

  def edit(%Conn{assigns: %{user_profile: user_profile}} = conn, _) do
    changeset = Profile.changeset(user_profile)
    render(conn, "edit.html", title: "Edit Profile", user_profile: user_profile, changeset: changeset, single_fields: Profile.single_fields, array_fields: Profile.array_fields)
  end

  def update(%Conn{assigns: %{user_profile: user_profile, auth_status: :success}} = conn, %{"profile" => profile_params}) do
    changeset = Profile.changeset_for_ldap(user_profile, profile_params)
    if changeset.valid? do
      changeset
      |> LdapRepo.update
      |> case do
        {:error, reason} -> conn
            |> ErrorHandler.fail(reason)
            |> render("edit.html", user_profile: user_profile, changeset: changeset, single_fields: Profile.single_fields, array_fields: Profile.array_fields)
        {:ok, _profile} ->
          handle_photo_update(conn, changeset)
      end
    else
      conn
      |> put_flash(:error, changeset.errors)
      |> render("edit.html", title: "My Profile", user_profile: user_profile, changeset: changeset, single_fields: Profile.single_fields, array_fields: Profile.array_fields)
    end
  end
  def update(%Conn{assigns: %{user_profile: user_profile, auth_status: :failure}} = conn, %{"profile" => profile_params}) do
    changeset = Profile.changeset_for_ldap(user_profile, profile_params)
    render(conn, "edit.html", title: "My Profile", user_profile: user_profile, changeset: changeset, single_fields: Profile.single_fields, array_fields: Profile.array_fields)
  end

  def handle_photo_update(conn, changeset) do
    case Map.has_key?(changeset.changes, :jpegPhoto) do
      true  -> update_photo(conn, changeset)
      false -> build_success_conn(conn)
    end
  end

  def update_photo(%Conn{assigns: %{user_profile: user_profile}} = conn, changeset) do
    case PhotoHandler.update_photo(user_profile.uid) do
      :ok ->
        build_success_conn(conn)
      {:error, _error} ->
        conn
        |> put_flash(:error, ["There was a problem updating your photo on the directory page.  Please open a Help Desk ticket for assistance."])
        |> render("edit.html", title: "My Profile", user_profile: user_profile, changeset: changeset, single_fields: Profile.single_fields, array_fields: Profile.array_fields)
    end
  end

  def build_success_conn(conn) do
    conn
    |> put_flash(:info, "Successfully updated your profile!")
    |> redirect(to: settings_profile_path(conn, :show))
  end

end
