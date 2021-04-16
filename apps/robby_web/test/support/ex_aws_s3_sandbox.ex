defmodule RobbyWeb.ExAws.S3.Sandbox do
  @moduledoc """
  Sandbox service mock for S3 uploads.

  Example response:

      {:ok,
        %{
          body: "",
          headers: [
            {"x-amz-id-2", "9999999999999999999999999999999999999999999999999999999999999999X99999999999"},
            {"x-amz-request-id", "9999999999999999"},
            {"Date", "Thu, 04 Jan 2018 22:50:44 GMT"},
            {"ETag", "99999999999999999999999999999999"},
            {"Content-Length", "0"},
            {"Server", "AmazonS3"}
          ],
          request_url: "https://example-bucket.s3.example.com/robby.jpg",
          status_code: 200
        }
      }

  """

  def put_object(s3_bucket, destination, source, opts \\ [])
  def put_object(_s3_bucket, "robby.jpg", source, _opts), do: {:ok, source}
  def put_object(_s3_bucket, "matt.jpg", source, _opts), do: {:ok, source}

  def put_object(_s3_bucket, "clippy.jpg", _source, _opts),
    do: {:error, amazon_response("clippy.jpg")}

  def put_object(_s3_bucket, "jim.jpg", _source, _opts), do: {:error, amazon_response("jim.jpg")}

  def put_object(_s3_bucket, _destination, _source, _opts),
    do: "This is clearly quite unexpected."

  defp amazon_response("clippy.jpg") do
    {:error,
     %{
       body: "",
       headers: [
         {"x-amz-id-2",
          "9999999999999999999999999999999999999999999999999999999999999999X99999999999"},
         {"x-amz-request-id", "9999999999999999"},
         {"Date", "Thu, 04 Jan 2018 22:50:44 GMT"},
         {"ETag", "99999999999999999999999999999999"},
         {"Content-Length", "0"},
         {"Server", "AmazonS3"}
       ],
       request_url: "https://example-bucket.s3.example.com/clippy.jpg",
       status_code: 302
     }}
  end

  defp amazon_response("jim.jpg") do
    {:error,
     %{
       body: "",
       headers: [
         {"x-amz-id-2",
          "9999999999999999999999999999999999999999999999999999999999999999X99999999999"},
         {"x-amz-request-id", "9999999999999999"},
         {"Date", "Thu, 04 Jan 2018 22:50:44 GMT"},
         {"ETag", "99999999999999999999999999999999"},
         {"Content-Length", "0"},
         {"Server", "AmazonS3"}
       ],
       request_url: "https://example-bucket.s3.example.com/jim.jpg",
       status_code: 403
     }}
  end
end
