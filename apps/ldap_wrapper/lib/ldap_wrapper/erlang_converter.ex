defmodule LdapWrapper.ErlangConverter do
  def convert_to_erlang(list) when is_list(list), do: Enum.map(list, &convert_to_erlang/1)
  def convert_to_erlang(string) when is_binary(string), do: :binary.bin_to_list(string)

  def convert_to_erlang(atom) when is_atom(atom),
    do: atom |> Atom.to_string() |> convert_to_erlang

  def convert_to_erlang(num) when is_number(num), do: num

  def convert_from_erlang(list = [head | _]) when is_list(head),
    do: Enum.map(list, &convert_from_erlang/1)

  def convert_from_erlang(string) when is_list(string), do: :binary.list_to_bin(string)
  def convert_from_erlang(other), do: other
end
