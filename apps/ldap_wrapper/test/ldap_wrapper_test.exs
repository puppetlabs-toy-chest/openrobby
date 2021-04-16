defmodule LdapWrapperTest do
  use ExUnit.Case
  alias LdapWrapper.Ldap.Sandbox

  setup do
    {:ok, handle} = Sandbox.open(["ldap.example.com"], [636, true])
    {:ok, handle: handle}
  end

  test "connect returns {:ok, handle} with valid connection options" do
  {response, handle} = LdapWrapper.connect(["ldap.example.com"], 636, true)
  assert response == :ok
  assert is_pid handle
  end

  test "disconnect returns :ok", meta do
    assert LdapWrapper.disconnect(meta[:handle]) == :ok
  end

  test "authenticate returns an error if sent invalid credentials", meta do
    assert LdapWrapper.authenticate(meta[:handle], "user", "mychildrensnames") == {:error, :invalidCredentials}
  end

  test "authenticate with valid credentials returns ok", meta do
    assert LdapWrapper.authenticate(meta[:handle], "uid=tom,ou=users,dc=example,dc=com", "cattbutt") == :ok
  end

#  test "ldap_api.search receives a message with search space and options", meta do
#    LdapWrapper.search_ldap(meta[:handle], "example@email.com", "ou=users,dc=example,dc=com", "mail", [:dn, :uid, :objectClass, :mail, :mobile])
#    assert_received {:search, handle, [base: 'ou=users,dc=example,dc=com',filter: {:equalityMatch, 'mail', 'example@email.com'}, attributes: ['dn', 'uid', 'objectClass', 'mail', 'mobile']]}
#  end

  test "search_ldap returns a map of requested attributes for a given user", meta do
    assert LdapWrapper.search_ldap(meta[:handle], "jane@example.com", "ou=users,dc=example,dc=com", "mail", [:dn, :uid, :objectClass, :mail, :mobile]) ==
    [%{dn: "uid=jane,ou=users,dc=example,dc=com", uid: ["jane"],
        objectClass: ["inetOrgPerson", "posixAccount", "shadowAccount",
          "organizationalPerson", "person", "top", "orgPerson"],
        mail: ["jane@example.com"]}]
  end

  test "ldap search by email returns a map of desired attributes to arrays of their values", meta do
    assert LdapWrapper.search_by_email(meta[:handle], "jane@example.com", "ou=users,dc=example,dc=com", [:dn, :uid, :objectClass, :mail, :mobile]) ==
    [%{dn: "uid=jane,ou=users,dc=example,dc=com", uid: ["jane"],
        objectClass: ["inetOrgPerson", "posixAccount", "shadowAccount",
          "organizationalPerson", "person", "top", "orgPerson"],
        mail: ["jane@example.com"]}]
  end

  test "set password calls the appropriate ldap function", meta do
    LdapWrapper.set_password(meta[:handle], "uid=jane,ou=users,dc=example,dc=com", "password1234")
    assert_received {:modify_password, 'uid=jane,ou=users,dc=example,dc=com', 'password1234'}
  end

  test "change password calls the appropriate ldap function", meta do
    LdapWrapper.change_password(meta[:handle], "uid=tom,ou=users,dc=example,dc=com", "doggbutt", "cattbutt")

    assert_received {:modify_password, 'uid=tom,ou=users,dc=example,dc=com', 'doggbutt', 'cattbutt'}
  end

  def dn(name) do
    "uid=#{name},ou=users,dc=example,dc=com"
  end

  def entry(name) do
    [ {'uid',         ['#{name}']},
      {'objectClass', ['inetOrgPerson',
                       'posixAccount',
                       'shadowAccount',
                       'organizationalPerson',
                       'person',
                       'top',
                       'orgPerson']},
      {'mail',        ['#{name}@example.com']}]
  end

  test "Given the eldap atom, the distinguished name, and a valid LDAP entry, a map is returned" do
    hash = LdapWrapper.convert_eldap_entry_to_map({:eldap_entry, dn("jim"), entry("jim")})
    assert hash[:dn] =~ dn("jim")
    assert Enum.member?(hash[:uid], "jim")
    assert Enum.member?(hash[:mail], "jim@example.com")
  end

  test "If the search results are ok, parse the result set and send back a list of maps" do
    jim_eldap_entry = {:eldap_entry, dn("jim"), entry("jim")}
    tom_eldap_entry = {:eldap_entry, dn("tom"), entry("tom")}
    result = {:eldap_search_result, [jim_eldap_entry, tom_eldap_entry], []}
    list = LdapWrapper.parse_search_results({:ok, result})
    assert is_list(list)
  end

  test "If the LDAP response is :ldap_closed, respond with a disconnect/retry error" do
    assert LdapWrapper.parse_search_results({:error, :ldap_closed}) == {:error, {:disconnected, :retry}}
  end
end
