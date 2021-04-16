defmodule RobbyWeb.PageControllerTest do
  use RobbyWeb.ConnCase

  test "GET /" do
    conn = get build_conn(), "/"
    assert html_response(conn, 200) =~ "Welcome to Robby"
  end
end
