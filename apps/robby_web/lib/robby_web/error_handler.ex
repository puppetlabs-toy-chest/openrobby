defmodule RobbyWeb.ErrorHandler do
  import Phoenix.Controller, only: [put_flash: 3]
  require Logger

  def fail(conn, :too_short),
    do:
      conn
      |> put_flash(
        :error,
        "Password is too short, must be at least #{conn.assigns.max_effective_policy.min_length} characters"
      )

  def fail(conn, :too_simple),
    do:
      conn
      |> put_flash(
        :error,
        "Password is too simple, must have at least #{
          conn.assigns.max_effective_policy.min_char_classes
        } character classes"
      )

  def fail(conn, :not_printable),
    do: conn |> put_flash(:error, "Password contains unprintable characters")

  def fail(conn, :invalidCredentials), do: conn |> put_flash(:error, "Invalid Credentials")
  def fail(conn, {:error, message}), do: conn |> put_flash(:error, message |> to_string)

  def fail(conn, message) do
    conn |> put_flash(:error, message |> to_string)
  end
end
