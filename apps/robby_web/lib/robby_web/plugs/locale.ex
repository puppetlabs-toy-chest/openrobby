defmodule RobbyWeb.Plugs.Locale do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _opts) do
    case conn.params["locale"] || get_session(conn, :locale) do
      nil ->
        conn

      locale ->
        Gettext.put_locale(RobbyWeb.Gettext, locale)
        conn |> put_session(:locale, locale)
    end
  end
end
