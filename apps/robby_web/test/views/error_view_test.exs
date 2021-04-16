defmodule RobbyWeb.ErrorViewTest do
  use RobbyWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(RobbyWeb.ErrorView, "404.html", []) =~
           "Page Not Found"
  end

  test "render 500.html" do
    assert render_to_string(RobbyWeb.ErrorView, "500.html", []) =~
           "Server Internal Error"
  end

  test "render any other" do
    assert render_to_string(RobbyWeb.ErrorView, "505.html", []) =~
           "Server Internal Error"
  end
end
