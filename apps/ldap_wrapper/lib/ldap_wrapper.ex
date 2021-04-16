defmodule LdapWrapper do
  import LdapWrapper.ErlangConverter

  def ldap_api do
    Application.get_env(:ldap_wrapper, :ldap_api, :eldap)
  end

  def connect(hosts, port \\ 389, use_ssl \\ false) do
    ldap_api().open(convert_to_erlang(hosts), [{:port, port}, {:ssl, use_ssl}])
  end

  def disconnect(handle) do
    ldap_api().close(handle)
  end

  def authenticate(handle, dn, password) do
    ldap_api().simple_bind(
      handle,
      convert_to_erlang(dn),
      convert_to_erlang(password)
    )
  end

  def change_password(handle, dn, new_password, old_password) do
    result =
      authenticate(handle, dn, old_password)
      |> case do
        {:error, msg} ->
          IO.inspect({:error, msg})

        :ok ->
          ldap_api().modify_password(
            handle,
            convert_to_erlang(dn),
            convert_to_erlang(new_password),
            convert_to_erlang(old_password)
          )
          |> case do
            {:error, msg} ->
              IO.inspect({:error, msg})

            :ok ->
              :ok
          end
      end

    disconnect(handle)
    result
  end

  def set_password(handle, dn, new_password) do
    ldap_api().modify_password(
      handle,
      convert_to_erlang(dn),
      convert_to_erlang(new_password)
    )
  end

  def modify(handle, dn, mod_operations) do
    mod_operations
    |> Enum.group_by(fn {_, type, _} -> type end)
    |> IO.inspect()

    ldap_api().modify(
      handle,
      convert_to_erlang(dn),
      mod_operations
    )
  end

  def search_by_email(handle, email, base, attributes) do
    search_ldap(handle, email, base, "mail", attributes)
  end

  def search_ldap(handle, search_term, base, filter_type, attributes) do
    filter =
      ldap_api().equalityMatch(
        convert_to_erlang(filter_type),
        convert_to_erlang(search_term)
      )

    erl_attributes = convert_to_erlang(attributes)
    erl_base = convert_to_erlang(base)

    handle
    |> ldap_api().search(base: erl_base, filter: filter, attributes: erl_attributes)
    |> parse_search_results
  end

  def parse_search_results({:ok, result}), do: parse_search_results(result)

  def parse_search_results({:error, :ldap_closed}), do: {:error, {:disconnected, :retry}}

  def parse_search_results({:eldap_search_result, entry_list, []}) when is_list(entry_list) do
    entry_list
    |> Enum.map(&convert_eldap_entry_to_map/1)
  end

  def convert_eldap_entry_to_map({:eldap_entry, dn, entry}) do
    entry
    |> Enum.into(
      %{:dn => convert_from_erlang(dn)},
      fn {k, v} -> {List.to_atom(k), convert_from_erlang(v)} end
    )
  end
end
