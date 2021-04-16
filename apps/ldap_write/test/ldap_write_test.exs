defmodule LdapWriteWorkerTest do
  use ExUnit.Case

  alias LdapWrite.Worker

  test "given a valid connection, user_dn, and password, do_write returns :ok" do
    assert Worker.write_password("uid=tom,ou=users,dc=example,dc=com", "new_password") == :ok
  end

  test "given an error message from LDAP, handle_write_results returns the appropriate error message" do
    assert Worker.handle_write_results({:error, {:response, :ldap_reason}}) == {:error, :ldap_reason}
    assert Worker.handle_write_results(:ok) == :ok
    assert Worker.handle_write_results(:message)== {:error, :message}
  end


  defp changeset(params) do
    %{action: nil,
      changes: params,
      constraints: [], errors: [], filters: %{},
      model: %{favouriteDrink: nil, cn: nil, languages: [], sshPublicKey: [], ou: [], dietaryRestrictions: nil, stateOrProvinceName: nil,
        employeeNumber: nil, mobile: nil,
        bribeMeWith: "skittles", employeeType: nil, hasSubordinates: nil,
        personalTitle: nil, title: nil,
        dn: "uid=jim,ou=users,dc=example,dc=com", countryName: nil,
        shirtSize: nil, twitterHandle: nil, l: nil, ircNickname: nil,
        steamAccount: nil, manager: nil, onCall: nil, github: nil,
        skills: ["tying knots", "breaking rocks", "matching socks"], id: nil,
        googleGroups: nil, projects: nil, pseudonym: "nickname", st: nil,
        jpegPhoto: nil, mail: nil, interestingFact: nil, pronoun: nil,
        slackUsername: nil},
      optional: [:cn, :mail, :mobile, :employeeNumber, :employeeType,
        :stateOrProvinceName, :jpegPhoto, :title, :bribeMeWith, :countryName,
        :dietaryRestrictions, :favouriteDrink, :github, :hasSubordinates,
        :interestingFact, :ircNickname, :languages, :manager, :onCall, :ou,
        :personalTitle, :projects, :pronoun, :pseudonym, :shirtSize, :skills,
        :steamAccount, :twitterHandle, :sshPublicKey, :googleGroups, :l, :st,
        :slackUsername],
      opts: [], params: "not important", prepare: [], repo: nil,
      required: [:dn],
      types: %{favouriteDrink: :string, cn: :string, languages: {:array, :string},
        sshPublicKey: {:array, :binary}, ou: {:array, :string},
        dietaryRestrictions: :string, stateOrProvinceName: :string,
        employeeNumber: :string, mobile: :string, bribeMeWith: :string,
        employeeType: :string, hasSubordinates: :string, personalTitle: :string,
        title: :string, dn: :string, countryName: :string, shirtSize: :string,
        twitterHandle: :string, l: :string, ircNickname: :string,
        steamAccount: :string, manager: :string, onCall: :string, github: :string,
        skills: {:array, :string}, id: :id, googleGroups: :string, projects: :string,
        pseudonym: :string, st: :string, jpegPhoto: :binary, mail: :string,
        interestingFact: :string, pronoun: :string, slackUsername: :string,},
        valid?: true, validations: []}
  end

  test "given a profile changeset, categorize_changes returns the right list of ldap modification operations" do
    changeset = changeset(%{skills: ["elixir", "ruby", "breaking rocks"]})
    assert Worker.categorize_changes(changeset) ==
    [
      {:ModifyRequest_changes_SEQOF, :add,
        {:PartialAttribute, 'skills',
          ["elixir"]}},
      {:ModifyRequest_changes_SEQOF, :add,
        {:PartialAttribute, 'skills',
          ["ruby"]}},
      {:ModifyRequest_changes_SEQOF, :delete,
        {:PartialAttribute, 'skills',
          ["matching socks"]}},
      {:ModifyRequest_changes_SEQOF, :delete,
        {:PartialAttribute, 'skills',
          ["tying knots"]}},
    ]
    changeset2 = changeset(%{interestingFact: "Junko Tabei may appear slight, almost fragile looking, but the Japanese mountaineer has a steely determination that helped her to become the first woman to reach Everest's apex. In 1975, Tabei was chosen as one of 15 in the first all-female team to take on the mountain.", pseudonym: "jiff", bribeMeWith: nil})
    assert Worker.categorize_changes(changeset2) ==
    [
      {:ModifyRequest_changes_SEQOF, :delete,
        {:PartialAttribute, 'bribeMeWith',
          ["skittles"]}},
      {:ModifyRequest_changes_SEQOF, :add,
        {:PartialAttribute, 'interestingFact',
          ["Junko Tabei may appear slight, almost fragile looking, but the Japanese mountaineer has a steely determination that helped her to become the first woman to reach Everest's apex. In 1975, Tabei was chosen as one of 15 in the first all-female team to take on the mountain."]}},
      {:ModifyRequest_changes_SEQOF, :replace,
        {:PartialAttribute, 'pseudonym',
          ["jiff"]}},
    ]

  changeset3 = changeset(%{skills: ["tying knots", "breaking rocks", "matching socks", "trolling"], languages: ["Tagalog", "Malagasy", "Woods Cree"], bribeMeWith: "socks to match"})
    assert Worker.categorize_changes(changeset3) ==
    [
      {:ModifyRequest_changes_SEQOF, :replace,
        {:PartialAttribute, 'bribeMeWith',
          ["socks to match"]}},
      {:ModifyRequest_changes_SEQOF, :add,
        {:PartialAttribute, 'languages',
          ["Malagasy"]}},
      {:ModifyRequest_changes_SEQOF, :add,
        {:PartialAttribute, 'languages',
          ["Tagalog"]}},
      {:ModifyRequest_changes_SEQOF, :add,
        {:PartialAttribute, 'languages',
          ["Woods Cree"]}},
      {:ModifyRequest_changes_SEQOF, :add,
        {:PartialAttribute, 'skills', ["trolling"]}}
    ]
  end
end
