defmodule RobbyWeb.PhotoUploaderTest do
  use ExUnit.Case
  alias RobbyWeb.PhotoUploader

  @robby_photo "priv/static/images/robby.png"

  test "will return ok when upload is successful" do
    {:ok, @robby_photo, _message} = PhotoUploader.upload_photo(@robby_photo, "robby")
  end

  test "will return error when upload fails" do
    {:error, @robby_photo, _error} = PhotoUploader.upload_photo(@robby_photo, "clippy")
  end

  test "will raise exception when AWS response is unhandled" do
    assert_raise RuntimeError, fn ->
      PhotoUploader.upload_photo(@robby_photo, "bobby")
    end
  end
end
