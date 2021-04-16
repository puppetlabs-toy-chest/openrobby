defmodule RobbyWeb.Profile do
  use RobbyWeb.Web, :model
  alias RobbyWeb.Profile
  alias RobbyWeb.LdapRepo
  alias RobbyWeb.ProfileHelper
  import RobbyWeb.Gettext
  require Logger

  @primary_key {:dn, :string, autogenerate: false}
  schema "users" do
    field :bribeMeWith, :string
    field :cn, :string
    field :dietaryRestrictions, :string
    field :employeeNumber, :string
    field :favouriteDrink, :string
    field :github, :string
    field :googleGroups, :string
    field :hasSubordinates, :string
    field :interestingFact, :string
    field :ircNickname, :string
    field :jpegPhoto, :binary
    field :labeledURI, :string
    field :languages, {:array, :string}
    field :mail, :string
    field :manager, :string
    field :mobile, :string
    field :objectClass, {:array, :string}
    field :onCall, :string
    field :ou, {:array, :string}
    field :personalTitle, :string
    field :physicalDeliveryOfficeName, :string
    field :projects, {:array, :string}
    field :pronoun, :string
    field :pseudonym, :string
    field :shirtSize, :string
    field :skills, {:array, :string}
    field :slackUsername, :string
    field :sshPublicKey, {:array, :string}
    field :startDate, :naive_datetime
    field :steamAccount, :string
    field :telephoneNumber, :string
    field :title, :string
    field :twitterHandle, :string
    field :uid, :string
  end

  gettext("bribeMeWith")
  gettext("cn")
  gettext("dietaryRestrictions")
  gettext("direct_reports")
  gettext("dn")
  gettext("employeeNumber")
  gettext("favouriteDrink")
  gettext("github")
  gettext("googleGroups")
  gettext("hasSubordinates")
  gettext("interestingFact")
  gettext("ircNickname")
  gettext("jpegPhoto")
  gettext("labeledURI")
  gettext("languages")
  gettext("mail")
  gettext("manager")
  gettext("mobile")
  gettext("objectClass")
  gettext("onCall")
  gettext("ou")
  gettext("personalTitle")
  gettext("physicalDeliveryOfficeName")
  gettext("projects")
  gettext("pronoun")
  gettext("pseudonym")
  gettext("shirtSize")
  gettext("skills")
  gettext("slackUsername")
  gettext("sshPublicKey")
  gettext("steamAccount")
  gettext("telephoneNumber")
  gettext("title")
  gettext("twitterHandle")
  gettext("uid")

  @required_fields ~w(dn objectClass)a

  @optional_fields ~w(cn mail mobile employeeNumber jpegPhoto title bribeMeWith dietaryRestrictions labeledURI favouriteDrink github hasSubordinates interestingFact ircNickname languages manager onCall ou personalTitle projects pronoun pseudonym shirtSize skills steamAccount twitterHandle sshPublicKey googleGroups uid telephoneNumber physicalDeliveryOfficeName slackUsername)a

  @writable_fields ~w(github steamAccount interestingFact twitterHandle ircNickname shirtSize dietaryRestrictions bribeMeWith mobile personalTitle labeledURI pseudonym projects drink pronoun sshPublicKey skills languages telephoneNumber slackUsername)a

  def orgPeople do
    ProfileHelper.orgPeople(RobbyWeb.Profile)
  end

  def single_fields do
    :types
    |> __schema__
    |> Stream.filter(fn {field, _} -> @writable_fields |> Enum.member?(field) end)
    |> Enum.filter(fn {_, type} -> is_atom(type) end)
    |> Keyword.keys
  end

  def array_fields do
    :fields
    |> __schema__
    |> MapSet.new
    |> MapSet.difference(MapSet.new(single_fields()))
    |> MapSet.intersection(MapSet.new(@writable_fields))
  end

  def array_fields(:s), do: Enum.map(array_fields(), &to_string/1)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, List.flatten(@required_fields, @optional_fields))
    |> validate_required(@required_fields)
  end

  defp decode_photo_if_necessary(params = %{"jpegPhoto" => [Plug.Upload, _type, _file, path]}) do
    binary =
      path
      |> File.read!
    Map.put(params, "jpegPhoto", binary)
  end
  defp decode_photo_if_necessary(params), do: params

  def changeset_for_ldap(model, params \\ :empty) do
    parsed_params =
      params
      |> parse_params
      |> decode_photo_if_necessary
    model
    |> changeset(parsed_params)
  end

  defp parse_params(params) do
    for {att, val} <- params, into: %{}, do: {att, parse_param({att,val})}
  end

  defp parse_param({_att, val}) when is_map(val) do
    val
    |> Map.values
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq
  end
  defp parse_param({att, val}) do
    cond do
      Enum.member?(array_fields(:s), att) && val -> [val]
      Enum.member?(array_fields(:s), att)        -> []
      true                                       -> val
    end
  end

  def get_photo(uid) do
    Logger.debug "Retrieving photo from LDAP for user #{inspect uid}"

    LdapRepo.get_by(Profile, uid: uid)
    |> Map.get(:jpegPhoto)
  end
end
