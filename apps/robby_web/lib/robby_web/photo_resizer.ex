defmodule RobbyWeb.PhotoResizer do
  require Logger
  import Mogrify
  alias RobbyWeb.Profile

  @enoent "the file does not exist"
  @eacces "missing permission for the file or one of its parents"
  @eperm "the file is a directory and user is not super-user"
  @enotdir "a component of the file name is not a directory; on some platforms, :enoent is returned instead"
  @einval "filename had an improper type, such as tuple"

  @doc """
  Performs an image resize operation on a given LDAP photo and returns
  the path of the temporary image file.

  ## Arguments
      `uid`  The LDAP User ID for which the photo will be resized
  """
  @spec resize_image(String.t()) :: {:ok, String.t() | :no_photo}
  def resize_image(uid) do
    Logger.debug("Starting image resize")

    path =
      uid
      |> Profile.get_photo()
      |> create_tmp_file(uid)
      |> resize_tmp_file

    {:ok, path}
  end

  defp create_tmp_file(nil, uid) do
    Logger.warn("No photo found in LDAP for user #{inspect(uid)}")
    :no_photo
  end

  defp create_tmp_file(binary, uid) do
    Logger.debug("Making temporary photo file for uid #{inspect(uid)}")

    filename = generate_photo_filename(uid)

    Logger.debug("Writing to file: #{inspect(filename)}")
    File.write!(filename, binary)
    filename
  end

  def generate_photo_filename(uid) do
    "#{uid}_photo.jpg"
    |> Path.absname()
  end

  defp resize_tmp_file(:no_photo), do: :no_photo

  defp resize_tmp_file(path) do
    Logger.debug("Resizing temp file")

    open(path)
    |> resize("400x400^")
    |> extent("400x400 -gravity center")
    |> save(in_place: true)
    |> Map.get(:path)
  end

  @doc """
  Cleans up temporary photo file from resize operation.

  ## Arguments
      `path` The path of the temporary file
  """
  @spec cleanup_tmp_file(String.t()) :: :ok | {:error, String.t()}
  def cleanup_tmp_file(path) do
    Logger.debug("Deleting file #{inspect(path)}")

    message =
      case File.rm(path) do
        :ok -> :ok
        {:error, :enoent} -> @enoent
        {:error, :eacces} -> @eacces
        {:error, :eperm} -> @eperm
        {:error, :enotdir} -> @enotdir
        {:error, :einval} -> @einval
        {:error, error} -> "Unable to delete file: #{inspect(error)}"
      end

    case message do
      :ok -> :ok
      _not_ok -> {:error, message}
    end
  end
end
