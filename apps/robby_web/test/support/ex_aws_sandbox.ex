defmodule RobbyWeb.ExAws.Sandbox do

  @moduledoc """
  Sandbox service mock for AWS.

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

  def request!(%ExAws.Operation.S3{path: "robby.jpg"} = operation),      do: amazon_response("robby.jpg")
  def request!(%ExAws.Operation.S3{path: "matt.jpg"} = operation),      do: amazon_response("matt.jpg")
  def request!(%ExAws.Operation.S3{path: "clippy.jpg"} = operation),     do: amazon_response("clippy.jpg")
  def request!(%ExAws.Operation.S3{path: "jim.jpg"} = operation), do: amazon_response("jim.jpg")
  def request!(_unknown_operation), do: raise "Operation Failed"

  defp amazon_response("robby.jpg") do
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
  end

  defp amazon_response("matt.jpg") do
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
      request_url: "https://example-bucket.s3.example.com/matt.jpg",
      status_code: 200
    }
  end

  defp amazon_response("clippy.jpg") do
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
      request_url: "https://example-bucket.s3.example.com/clippy.jpg",
      status_code: 302
    }
  end

  defp amazon_response("jim.jpg") do
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
      request_url: "https://example-bucket.s3.example.com/jim.jpg",
      status_code: 403
    }
  end
end
