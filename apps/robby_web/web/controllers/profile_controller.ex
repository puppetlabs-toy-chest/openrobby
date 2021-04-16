defmodule RobbyWeb.ProfileController do
  use RobbyWeb.Web, :controller

  alias RobbyWeb.Profile
  alias RobbyWeb.LdapRepo
  alias RobbyWeb.Emailer
  import RobbyWeb.Gettext

  plug RobbyWeb.Plugs.LoadEmployeeIds

  def show(%Plug.Conn{params: %{"id" => id}} = conn, _) do
    case LdapRepo.get_by(Profile, uid: id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(RobbyWeb.ErrorView)
        |> render("404.html")
      profile ->
        manager = manager_for(profile.manager)
        reports = direct_reports_for(profile)
        render(conn, "show.html", title: profile.cn, user_profile: profile, manager: manager, reports: reports)
    end
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

  def photo_complaint(conn, %{"id" => id}) do
    user_profile = LdapRepo.get_by(Profile, uid: id)
    Emailer.send_profile_picture_complaint(user_profile.mail)
    flash_text = gettext "Successfully sent anonymous email to %{name} requesting a profile picture update.", name: user_profile.cn
    conn
    |> put_flash(:info, flash_text)
    |> redirect(to: profile_path(conn, :show, id))
  end
end
