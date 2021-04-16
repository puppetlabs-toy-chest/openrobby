defmodule LdapSearch.Worker do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    send(self(), :after_init)
    {:ok, []}
  end

  def handle_info(:after_init, _state) do
    {:ok, handle} = establish_connection()
    {:noreply, handle}
  end
  def handle_info(msg, state) do
    Logger.debug("#{__MODULE__} got a message it didn't know what to do with: #{inspect msg}. Throwing it away...")
    {:noreply, state}
  end

  defp establish_connection do
    {:ok, handle} = LdapWrapper.connect(ldap_hosts(), ldap_port(), ldap_use_ssl())
    :ok = LdapWrapper.authenticate(handle, ldap_bind_dn(), ldap_bind_password())
    {:ok, handle}
  end

  defp ldap_hosts do
    Application.get_env(:ldap_search, :hosts)
  end

  defp ldap_port do
    Application.get_env(:ldap_search, :port, 389)
  end

  defp ldap_use_ssl do
    Application.get_env(:ldap_search, :use_ssl, false)
  end

  defp ldap_base_rdn do
    Application.get_env(:ldap_search, :base_rdn)
  end

  defp ldap_bind_dn do
    Application.get_env(:ldap_search, :read_dn)
  end

  defp ldap_bind_password do
    Application.get_env(:ldap_search, :read_password)
  end

  def find_by_email(pid, email_address, attributes) when is_pid(pid) do
    GenServer.call(pid, {:find_by_email, email_address, attributes})
  end

  def find_by_email(email_address, attributes) do
    {:ok, handle} = establish_connection()
    {:reply, result, handle} = do_search(handle, email_address, attributes)
    LdapWrapper.disconnect(handle)
    result
  end

  def authenticate(dn, password) do
    {:ok, handle} = LdapWrapper.connect(ldap_hosts(), ldap_port(), ldap_use_ssl())
    result = LdapWrapper.authenticate(handle, dn, password)
    LdapWrapper.disconnect(handle)
    result
  end

  def handle_call({:find_by_email, email_address, attributes}, _from, handle) do
    do_search(handle, email_address, attributes)
  end

  def do_search(handle, email_address, attributes \\ [:dn, :objectClass, :mail, :mobile]) do
    LdapWrapper.search_by_email(handle, email_address, ldap_base_rdn(), attributes)
    |> case do
      {:error, {:disconnected, :retry}} ->
        LdapWrapper.disconnect(handle)
        {:ok, new_handle} = establish_connection()
        do_search(new_handle, email_address, attributes)
      search_results ->
        {:reply, search_results, handle}
    end
  end
end
