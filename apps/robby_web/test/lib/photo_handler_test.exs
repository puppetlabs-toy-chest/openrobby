defmodule RobbyWeb.PhotoHandlerTest do
  use ExUnit.Case
  alias RobbyWeb.PhotoHandler

  test "can successfully update a photo" do
    :ok = PhotoHandler.update_photo("matt")
  end

  test "can handle a missing photo gracefully" do
    :ok = PhotoHandler.update_photo("tom")
  end

  test "produces an error when there's an issue" do
    {:error, _message} = PhotoHandler.update_photo("jim")
  end

end
