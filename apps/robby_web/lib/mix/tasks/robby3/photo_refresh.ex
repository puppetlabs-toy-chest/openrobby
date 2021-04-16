defmodule Mix.Tasks.Robby3.PhotoRefresh do
  use Mix.Task
  require Logger
  alias RobbyWeb.{Directory, LdapRepo, PhotoHandler}

  @shortdoc "Refreshes S3 photo bucket with photos held in LDAP"
  @moduledoc """
  Issues a command to load photos from LDAP into the Robby3 S3 photo bucket.

  ## Usage

      $ mix robby3.photo_refresh luke

      $ mix robby3.photo_refresh --all

  ## Arguments

      --all
        Reloads all active employee photos.  Cannot be used in conjunction with any other arguments.

      `uid`
        Reloads photo for specified UID.  Cannot be used in conjunction with any other arguments.
  """

  @recursive false

  def run(opts) do
    {:ok, _started} = Application.ensure_all_started(:robby_web)
    process_refresh(opts)
    Logger.info("Photo refresh complete!")
  end

  defp process_refresh(["--all"]) do
    active_org_people()
    |> Enum.each(&update_photo/1)
  end

  defp process_refresh([uid]) do
    update_photo(uid)
  end

  defp update_photo(%Directory{uid: uid}), do: update_photo(uid)
  defp update_photo(uid), do: PhotoHandler.update_photo(uid)

  defp active_org_people() do
    Directory.orgPeople()
    |> LdapRepo.all()
  end
end
