defmodule RobbyWeb.PhotoResizerTest do
  use ExUnit.Case
  require Logger
  alias RobbyWeb.PhotoResizer

  test "will resize a photo with a predictable file location" do
    {:ok, path} = PhotoResizer.resize_image("matt")
    assert path == PhotoResizer.generate_photo_filename("matt")
  end

  test "will return :no_photo if a photo has not been provided" do
    assert {:ok, :no_photo} == PhotoResizer.resize_image("tom")
  end

  test "will remove the temporary file" do
    {:ok, path} = PhotoResizer.resize_image("matt")
    assert :ok == PhotoResizer.cleanup_tmp_file(path)
  end

  test "will produce file not found error if file is missing" do
    path = PhotoResizer.generate_photo_filename("tom")
    {:error, _message} = PhotoResizer.cleanup_tmp_file(path)
  end

end
