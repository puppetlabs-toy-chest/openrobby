defmodule RobbyWeb.PasswordPolicyTest do
  use RobbyWeb.ModelCase

  alias RobbyWeb.PasswordPolicy

  @valid_attrs %{min_char_classes: 42, min_length: 42, object_class: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PasswordPolicy.changeset(%PasswordPolicy{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PasswordPolicy.changeset(%PasswordPolicy{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "max_effective_policy chooses the most stringent option for character classes" do
    policy1 = %PasswordPolicy{object_class: "person", min_length: 45, min_char_classes: 1}
    policy2 = %PasswordPolicy{object_class: "nonperson", min_length: 23, min_char_classes: 3}
    assert (PasswordPolicy.max_effective_policy([policy1,policy2]).min_char_classes) == 3
    policy3 = %PasswordPolicy{object_class: "person", min_length: 0, min_char_classes: 1000}
    policy4 = %PasswordPolicy{object_class: "nonperson", min_length: 34, min_char_classes: 1000}
    assert (PasswordPolicy.max_effective_policy([policy1, policy2, policy3, policy4]).min_char_classes) == 1000
  end

  test "max_effective_policy chooses the most stringent option for length" do
    policy1 = %PasswordPolicy{object_class: "person", min_length: 45, min_char_classes: 1}
    policy2 = %PasswordPolicy{object_class: "nonperson", min_length: 23, min_char_classes: 3}
    assert (PasswordPolicy.max_effective_policy([policy1,policy2]).min_length) == 45
    policy3 = %PasswordPolicy{object_class: "person", min_length: 0, min_char_classes: 1000}
    policy4 = %PasswordPolicy{object_class: "nonperson", min_length: 34, min_char_classes: 1000}
    assert (PasswordPolicy.max_effective_policy([policy1, policy2, policy3, policy4]).min_length) == 45
  end

  test "max_effective_policy returns 0 min_length if there are no password policies for user" do
    assert (PasswordPolicy.max_effective_policy([]).min_length) == 0
  end

  test "max_effective_policy returns 0 min_char_classes if there are no password policies for user" do
    assert (PasswordPolicy.max_effective_policy([]).min_char_classes) == 0
  end

  test "passes? returns :ok if the password meets the given PasswordPolicy" do
    policy = %PasswordPolicy{object_class: "nonperson", min_length: 10, min_char_classes: 3}
    assert (PasswordPolicy.passes?(policy, "12345emandeni$$$")) == :ok
  end

  test "passes? returns {:error, reasons} if the password doesn't meet the given PasswordPolicy" do
    policy = %PasswordPolicy{object_class: "nonperson", min_length: 10, min_char_classes: 3}
    assert (PasswordPolicy.passes?(policy, "12345endienlai")) == {:error, :too_simple}
    assert (PasswordPolicy.passes?(policy, "13end@#$")) == {:error, :too_short}
    assert (PasswordPolicy.passes?(policy, "god123")) == {:error, :too_short}
    assert (PasswordPolicy.passes?(policy, "*****%%%%!!!!")) == {:error, :too_simple}
    assert (PasswordPolicy.passes?(policy, "🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀")) == {:error, :too_simple}
  end

  test "num_char_classes returns the number of distinct character classes" do
    assert (PasswordPolicy.num_char_classes("puggle") == 1)
    assert (PasswordPolicy.num_char_classes("dog eat dog") == 2)
    assert (PasswordPolicy.num_char_classes("i <3 my puggle") == 4)
  end

  test "has_upper? returns true for strings containing uppercase characters" do
    assert PasswordPolicy.has_upper?("Abcde") == true
  end
  test "has_upper? returns false for strings containing no uppercase characters" do
    assert PasswordPolicy.has_upper?("abcde") == false
  end

  test "has_lower? returns true for strings containing lowercase characters" do
    assert PasswordPolicy.has_lower?("aBCDE") == true
  end
  test "has_lower? returns false for strings containing no lowercase characters" do
    assert PasswordPolicy.has_lower?("ABCDE") == false
  end

  test "has_digit? returns true for strings containing digit characters" do
    assert PasswordPolicy.has_digit?("1bcde") == true
  end
  test "has_digit? returns false for strings containing no digit characters" do
    assert PasswordPolicy.has_digit?("abcde") == false
  end

  test "has_punct? returns true for strings containing punctuation characters" do
    assert PasswordPolicy.has_punct?("A!bcde") == true
  end
  test "has_punct? returns false for strings containing no punctuation characters" do
    assert PasswordPolicy.has_punct?("abcde🚀") == false
  end

  test "has_space? returns true for strings containing whitespace characters" do
    assert PasswordPolicy.has_space?("Abc de") == true
  end
  test "has_space? returns false for strings containing no whitespace characters" do
    assert PasswordPolicy.has_space?("##aaa🚀2123-__") == false
  end

  test "unprintable? returns true for strings containing unprintable characters" do
    assert PasswordPolicy.unprintable?("\a\d\e\r\0") == true
  end
  test "unprintable? returns false for strings containing only printable characters" do
    assert PasswordPolicy.unprintable?("🚀") == false
    assert PasswordPolicy.unprintable?("\"\\'\nAbcde\b") == false
    assert PasswordPolicy.unprintable?("$¢") == false
    assert PasswordPolicy.unprintable?("\"") == false
    assert PasswordPolicy.unprintable?("\\") == false
    assert PasswordPolicy.unprintable?("\b") == false
  end
end
