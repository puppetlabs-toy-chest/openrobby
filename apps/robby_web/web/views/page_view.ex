defmodule RobbyWeb.PageView do
  use RobbyWeb.Web, :view

  def get_photo_url(uid, current_user) do
    "//robby-s3-bucket-path/#{uid}.jpg?#{current_user_photo(uid, current_user)}"
  end

  def get_aws_region(), do: Application.get_env(:ex_aws, :region, "us-west-2")

  defp current_user_photo(uid, %RobbyWeb.User{username: username}) do
    case uid == username do
      true  -> "#{:rand.uniform(1000)}"
      false -> ""
    end
  end

end
