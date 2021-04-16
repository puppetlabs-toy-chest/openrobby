defmodule RobbyWeb.Unauthorized do
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]
  alias RobbyWeb.Router.Helpers

  def init(opts), do: opts

  def call(conn, _) do
    conn
    |> put_flash(:error, "Unauthorizated: come back with some creds")
    |> redirect(to: Helpers.page_path(conn, :index))
  end
end
