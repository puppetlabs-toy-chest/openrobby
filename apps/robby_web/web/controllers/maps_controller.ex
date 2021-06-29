defmodule RobbyWeb.MapsController do
  use RobbyWeb.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, %{"id" => location}) do
    render(conn, "#{location}.html")
  end
end
