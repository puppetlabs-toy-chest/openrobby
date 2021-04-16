defmodule LdapSearchTest do
  use ExUnit.Case

  test "finding a non-existent email returns an empty list" do
    assert LdapSearch.find_by_email("not.a.real.email@example.com") == []
  end

  test "finding an existing email address returns that person" do
    assert LdapSearch.find_by_email("jane@example.com") ==
      [%{ dn: "uid=jane,ou=users,dc=example,dc=com",
          mail: ["jane@example.com"],
          objectClass: ["inetOrgPerson", "posixAccount", "shadowAccount", "organizationalPerson", "person", "top", "orgPerson"],
          uid: ["jane"]}]
  end

  test "finding an existing email address returns that user's profile" do
    assert LdapSearch.find_by_email("tom@example.com", [:*]) ==
      [%{dn: "uid=tom,ou=users,dc=example,dc=com",
              mail: ["tom@example.com"],
              objectClass: ["inetOrgPerson", "posixAccount",
               "shadowAccount", "organizationalPerson", "person",
               "top", "orgPerson"], uid: ["tom"]}]
    end
end
