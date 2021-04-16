defmodule LdapWrapper.ErlangConverterTest do
  use ExUnit.Case
  alias LdapWrapper.ErlangConverter

  test "convert_to_erlang of a string gives a char list" do
    assert ErlangConverter.convert_to_erlang("ldap.example.com") == 'ldap.example.com'
    assert ErlangConverter.convert_to_erlang("Sören") == [83,195,182,114,101,110]
    assert ErlangConverter.convert_to_erlang("🚀") == [240, 159, 154, 128]
  end

  test "convert_to_erlang of a list of strings gives a list of char lists" do
    assert ErlangConverter.convert_to_erlang(["ldap.example.com","hello"]) == ['ldap.example.com','hello']
    assert ErlangConverter.convert_to_erlang(["ldap.example.com", "Sören"]) == ['ldap.example.com', [83,195,182,114,101,110]]
  end

  test "convert_to_erlang of a number gives a number" do
    assert ErlangConverter.convert_to_erlang(83) == 83
  end

  test "convert_from_erlang of a char list gives a string" do
    assert ErlangConverter.convert_from_erlang('ldap.example.com') == "ldap.example.com"
    assert ErlangConverter.convert_from_erlang([83,195,182,114,101,110]) == "Sören"
    assert ErlangConverter.convert_from_erlang([240, 159, 154, 128]) == "🚀"
  end

  test "convert_from_erlang of a list of char lists gives a list of strings" do
    assert ErlangConverter.convert_from_erlang(['ldap.example.com','hello']) == ["ldap.example.com","hello"]
    assert ErlangConverter.convert_from_erlang(['ldap.example.com',[83,195,182,114,101,110]]) == ["ldap.example.com", "Sören"]
  end

  test "convert_from_erlang of a number gives a number" do
    assert ErlangConverter.convert_from_erlang(83) == 83
  end

end
