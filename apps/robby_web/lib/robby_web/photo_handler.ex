defmodule RobbyWeb.PhotoHandler do
  require Logger
  alias RobbyWeb.{PhotoResizer, PhotoUploader}

  @doc """
  Updates Robby photos by resizing the image stored in LDAP and pushing it to S3.

  ## Arguments
      `uid`  The LDAP UID of the user applying the photo update
  """
  @spec update_photo(String.t()) :: :ok | {:error, String.t()}
  def update_photo(uid) do
    Logger.info("Updating photo for uid #{inspect(uid)}")

    uid
    |> PhotoResizer.resize_image()
    |> upload_photo(uid)
  end

  defp upload_photo({:ok, :no_photo}, uid) do
    Logger.info("Skipping photo upload for uid #{inspect(uid)}, no photo found")
    :ok
  end

  defp upload_photo({:ok, path}, uid) do
    path
    |> PhotoUploader.upload_photo(uid)
    |> cleanup_temporary_file
  end

  defp cleanup_temporary_file({:ok, path, _response}) do
    PhotoResizer.cleanup_tmp_file(path)
    :ok
  end

  defp cleanup_temporary_file({:error, path, error_message}) do
    PhotoResizer.cleanup_tmp_file(path)
    {:error, error_message}
  end
end
