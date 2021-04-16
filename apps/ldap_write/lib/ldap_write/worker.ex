defmodule LdapWrite.Worker do
  require Logger

  defp establish_connection do
    {:ok, handle} = LdapWrapper.connect(ldap_hosts(), ldap_port(), ldap_use_ssl())
    :ok = LdapWrapper.authenticate(handle, ldap_bind_dn(), ldap_bind_password())
    {:ok, handle}
  end

  defp establish_connection_as_user(dn, password) do
    {:ok, handle} = LdapWrapper.connect(ldap_hosts(), ldap_port(), ldap_use_ssl())
    LdapWrapper.authenticate(handle, dn, password)
    |> case do
      :ok -> {:ok, handle}
      msg -> msg
    end
  end

  defp ldap_hosts do
    Application.get_env(:ldap_write, :hosts)
  end

  defp ldap_port do
    Application.get_env(:ldap_write, :port, 389)
  end

  defp ldap_use_ssl do
    Application.get_env(:ldap_write, :use_ssl, false)
  end

  defp ldap_bind_dn do
    Application.get_env(:ldap_write, :write_dn)
  end

  def change_password_as_user(dn, new_password, old_password) do
    case establish_connection_as_user(dn, old_password) do
      {:ok, handle} -> LdapWrapper.change_password(handle, dn, new_password, old_password)
             |> handle_write_results
      {:error, msg} -> {:error, msg}
    end
  end

  defp ldap_bind_password do
    Application.get_env(:ldap_write, :write_password)
  end

  def write_password(user_dn, new_password) do
    {:ok, handle} = establish_connection()
    result = LdapWrapper.set_password(handle, user_dn, new_password)
    |> handle_write_results
    LdapWrapper.disconnect(handle)
    result
  end

  def modify(changeset) do
    case establish_connection_as_user(changeset.model.dn, changeset.params["password"]) do
      {:ok, handle} ->
        operations = categorize_changes(changeset)
        result =
          LdapWrapper.modify(handle, changeset.model.dn, operations)
          |> handle_write_results

        LdapWrapper.disconnect(handle)
        result
      error -> error
    end
  end

  def categorize_changes(changeset) do
    for {attribute, new_val} <- changeset.changes do
      old_val = Map.get(changeset.model, attribute)
      ldap_attr = attribute |> to_charlist
      type = Map.get(changeset.types, attribute)
      ldap_operation(ldap_attr, type, old_val, new_val)
    end
    |> List.flatten
  end


  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                                                                           #
  # TODO: This entire method must be refactored.                              #
  #                                                                           #
  # I'm not sure how this is working.  It appears to hit the first function   #
  # head on every call, returning an empty array.  What is the behavior when  #
  # it does actually return something?  This must be documented and fixed.    #
  #                                                                           #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  defp categorize_single_changes(map,  _) when map == %{}, do: []
  defp categorize_single_changes(change_map, model) do
    for {attribute, new_val} <- change_map do
      old_val = Map.get(model, attribute)
      ldap_attr = attribute |> to_charlist
      ldap_operation(ldap_attr, old_val, new_val)
    end
  end

  def ldap_operation(attribute, {:array, type}, old_val, new_val) do
    old_set = MapSet.new(old_val)
    new_set = MapSet.new(new_val)

    [
      for add <- MapSet.difference(new_set, old_set) do
        ldap_operation(attribute, type, nil, add)
      end,
      for del <- MapSet.difference(old_set, new_set) do
        ldap_operation(attribute, type, del, nil)
      end
    ]
  end

  def ldap_operation(attribute, _, nil, new_val), do: :eldap.mod_add(attribute, [new_val])
  def ldap_operation(attribute, _, old_val, nil), do: :eldap.mod_delete(attribute, [old_val])
  def ldap_operation(attribute, _, _old_val, new_val), do: :eldap.mod_replace(attribute, [new_val])

  def handle_write_results({:error, {:response, ldap_reason}}), do: {:error, ldap_reason}
  def handle_write_results(:ok), do: :ok
  def handle_write_results(other), do: {:error, other}
end
