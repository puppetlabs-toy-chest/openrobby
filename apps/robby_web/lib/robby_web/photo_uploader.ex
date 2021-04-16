defmodule RobbyWeb.PhotoUploader do
  require Logger

  @doc """
  Uploads photo to S3 bucket.

  ## Arguments
      `path`  The path of the photo file to be uploaded
      `uid`   The User ID for the photo being sent to S3
  """
  @spec upload_photo(String.t, String.t) :: {:ok | :error, String.t, String.t}
  def upload_photo(path, uid) do
    Logger.debug "Pushing #{inspect path} for uid #{inspect uid} to S3"

    # TODO: Move photo bucket reference to configuration
    bucket   = "example-bucket"
    filename = "#{uid}.jpg"

    push_photo_to_s3(path, filename, bucket)
  end

  defp push_photo_to_s3(photo_filename, destination_filename, s3_bucket) do
    {status, response} = object_service().put_object(s3_bucket, destination_filename, File.read!(photo_filename), content_type: "image/jpeg", acl: :public_read)
    |> aws_service().request!
    |> case do
      %{status_code: 200} = response ->
        Logger.info("Successfully uploaded #{inspect destination_filename}; AWS response: #{inspect response}")
        {:ok, response}
      %{status_code: 302} = response ->
        Logger.error("Encountered an error uploading #{inspect destination_filename}; AWS response: #{inspect response}")
        {:error, response}
      %{status_code: 403} = response ->
        Logger.error("Encountered an error uploading #{inspect destination_filename}; AWS response: #{inspect response}")
        {:error, response}
      unhandled ->
        raise "Unhandled response from AWS for #{inspect destination_filename}: #{inspect unhandled}"
    end

    {status, photo_filename, response}
  end

  defp object_service() do
    Application.get_env(:ex_aws, :s3_adapter)
  end

  defp aws_service() do
    Application.get_env(:ex_aws, :adapter)
  end
end
