defmodule RobbyWeb.Ldap.Adapter.Sandbox do
  use GenServer
  require Logger

  @tom {:eldap_entry, 'uid=tom,ou=users,dc=example,dc=com',
        [
          {'uid', ['tom']},
          {'objectClass',
           [
             'inetOrgPerson',
             'posixAccount',
             'shadowAccount',
             'organizationalPerson',
             'person',
             'top',
             'orgPerson'
           ]},
          {'mail', ['tom@example.com']}
        ]}

  @jane {:eldap_entry, 'uid=jane,ou=users,dc=example,dc=com',
         [
           {'uid', ['jane']},
           {'objectClass',
            [
              'inetOrgPerson',
              'posixAccount',
              'shadowAccount',
              'organizationalPerson',
              'person',
              'top',
              'orgPerson'
            ]},
           {'mail', ['jane@example.com']}
         ]}

  @jim {:eldap_entry, 'uid=jim,ou=users,dc=example,dc=com',
        [
          {'cn', ['Jim']},
          {'displayName', ['Jim']},
          {'gidNumber', ['5000']},
          {'givenName', ['Jim']},
          {'homeDirectory', ['/home/jim']},
          {'jpegPhoto', [File.read!("priv/static/images/clippy.png")]},
          {'l', ['Portland']},
          {'loginShell', ['/bin/zsh']},
          {'mobile', ['8167392026']},
          {'mail', ['jim@example.com']},
          {'objectClass',
           ['posixAccount', 'shadowAccount', 'inetOrgPerson', 'ldapPublicKey', 'top']},
          {'skills', ['dad jokes', 'being awesome', 'elixir']},
          {'sn', ['jim']},
          {'sshPublicKey', ['ssh-rsa AAAA/TOTALLY+FAKE/KEY jim@example.com']},
          {'st', ['OR']},
          {'title', ['Principal Software Engineer']},
          {'uid', ['jim']},
          {'uidNumber', ['5001']}
        ]}

  @matt {:eldap_entry, 'uid=matt,ou=users,dc=example,dc=com',
         [
           {'cn', ['Matt']},
           {'displayName', ['Matt']},
           {'gidNumber', ['5000']},
           {'givenName', ['Matt']},
           {'homeDirectory', ['/home/matt']},
           {'jpegPhoto', [File.read!("priv/static/images/robby.png")]},
           {'l', ['Portland']},
           {'loginShell', ['/bin/bash']},
           {'mail', ['matt@example.com']},
           {'objectClass',
            ['posixAccount', 'shadowAccount', 'inetOrgPerson', 'ldapPublicKey', 'top']},
           {'skills', ['nunchuck', 'computer hacking', 'bowhunting']},
           {'sn', ['Batule']},
           {'sshPublicKey', ['ssh-rsa AAAA/TOTALLY+FAKE/KEY+2 matt@example.com']},
           {'st', ['OR']},
           {'title', ['Senior Software Engineer']},
           {'uid', ['matt']},
           {'uidNumber', ['5002']}
         ]}

  def init(_) do
    {:ok, [@jim, @matt]}
  end

  def search(pid, search_options) when is_list(search_options) do
    GenServer.call(pid, {:search, Map.new(search_options)})
  end

  def modify(pid, dn, modify_operations) do
    GenServer.call(pid, {:update, dn, modify_operations})
  end

  def handle_call(
        {:search, %{scope: :baseObject, base: 'uid=jim,ou=users,dc=example,dc=com'}},
        _from,
        state
      ) do
    ldap_response = {:ok, {:eldap_search_result, [List.first(state)], []}}
    {:reply, ldap_response, state}
  end

  def handle_call(
        {:search, %{scope: :baseObject, base: 'uid=matt,ou=users,dc=example,dc=com'}},
        _from,
        state
      ) do
    ldap_response = {:ok, {:eldap_search_result, [List.last(state)], []}}
    {:reply, ldap_response, state}
  end

  def handle_call({:search, %{scope: :baseObject}}, _from, state) do
    ldap_response = {:ok, {:eldap_search_result, [], []}}
    {:reply, ldap_response, state}
  end

  def handle_call(
        {:search,
         %{
           base: 'ou=users,dc=example,dc=com',
           filter:
             {:and,
              [
                and: [equalityMatch: {:AttributeValueAssertion, 'mail', 'jane@example.com'}],
                and: []
              ]}
         }},
        _from,
        state
      ) do
    ldap_response = {:ok, {:eldap_search_result, [@jane], []}}
    {:reply, ldap_response, state}
  end

  def handle_call(
        {:search,
         %{
           base: 'ou=users,dc=example,dc=com',
           filter:
             {:and,
              [
                and: [equalityMatch: {:AttributeValueAssertion, 'mail', 'jim@example.com'}],
                and: []
              ]}
         }},
        _from,
        state
      ) do
    ldap_response = {:ok, {:eldap_search_result, [@jim], []}}
    {:reply, ldap_response, state}
  end

  def handle_call(
        {:search,
         %{
           base: 'ou=users,dc=example,dc=com',
           filter:
             {:and,
              [
                and: [equalityMatch: {:AttributeValueAssertion, 'mail', 'tom@example.com'}],
                and: []
              ]}
         }},
        _from,
        state
      ) do
    ldap_response = {:ok, {:eldap_search_result, [@tom], []}}
    {:reply, ldap_response, state}
  end

  def handle_call(
        {:search,
         %{
           base: 'ou=users,dc=example,dc=com',
           filter:
             {:and, [and: [equalityMatch: {:AttributeValueAssertion, 'uid', 'jim'}], and: []]}
         }},
        _from,
        state
      ) do
    ldap_response = {:ok, {:eldap_search_result, [List.first(state)], []}}
    {:reply, ldap_response, state}
  end

  def handle_call(
        {:search,
         %{
           base: 'ou=users,dc=example,dc=com',
           filter:
             {:and, [and: [equalityMatch: {:AttributeValueAssertion, 'uid', 'tom'}], and: []]}
         }},
        _from,
        state
      ) do
    ldap_response = {:ok, {:eldap_search_result, [@tom], []}}
    {:reply, ldap_response, state}
  end

  def handle_call(
        {:search,
         %{
           base: 'ou=users,dc=example,dc=com',
           filter:
             {:and, [and: [equalityMatch: {:AttributeValueAssertion, 'uid', 'jane'}], and: []]}
         }},
        _from,
        state
      ) do
    ldap_response = {:ok, {:eldap_search_result, [@jane], []}}
    {:reply, ldap_response, state}
  end

  def handle_call(
        {:search,
         %{
           base: 'ou=users,dc=example,dc=com',
           filter:
             {:and, [and: [equalityMatch: {:AttributeValueAssertion, 'uid', 'jim'}], and: []]}
         }},
        _from,
        state
      ) do
    ldap_response = {:ok, {:eldap_search_result, [@jim], []}}
    {:reply, ldap_response, state}
  end

  def handle_call(
        {:search,
         %{
           base: 'ou=users,dc=example,dc=com',
           filter:
             {:and, [and: [equalityMatch: {:AttributeValueAssertion, 'uid', 'matt'}], and: []]}
         }},
        _from,
        state
      ) do
    ldap_response = {:ok, {:eldap_search_result, [@matt], []}}
    {:reply, ldap_response, state}
  end

  def handle_call(
        {:search,
         %{
           base: 'ou=users,dc=example,dc=com',
           filter:
             {:and, [and: [], and: [equalityMatch: {:AttributeValueAssertion, 'uid', 'jim'}]]}
         }},
        _from,
        state
      ) do
    ldap_response = {:ok, {:eldap_search_result, [List.first(state)], []}}
    {:reply, ldap_response, state}
  end

  def handle_call({:search, %{base: 'ou=users,dc=example,dc=com'}}, _from, state) do
    ldap_response = {:ok, {:eldap_search_result, state, []}}
    {:reply, ldap_response, state}
  end

  def handle_call({:search, search_options}, _from, state) do
    ldap_response = {:ok, {:eldap_search_result, [], []}}

    Logger.error(
      "! ! ! LDAP catch-all invoked ! ! !\nsearch_options: #{inspect(search_options)}\nstate: #{
        inspect(state)
      }"
    )

    {:reply, ldap_response, state}
  end

  def handle_call(
        {:update, 'uid=matt,ou=users,dc=example,dc=com', modify_operations},
        _from,
        state
      ) do
    {:eldap_entry, dn, attributes} = List.last(state)

    attribute_map = Enum.into(attributes, %{})

    updated_attributes =
      Enum.reduce(
        modify_operations,
        attribute_map,
        fn
          {:ModifyRequest_changes_SEQOF, :replace, {:PartialAttribute, attribute, []}},
          attribute_map ->
            Map.update!(attribute_map, attribute, fn _ -> nil end)

          {:ModifyRequest_changes_SEQOF, :replace, {:PartialAttribute, attribute, new_value}},
          attribute_map ->
            Map.update!(attribute_map, attribute, fn _ -> new_value end)
        end
      )
      |> Enum.to_list()

    updated_eldap_entry = {:eldap_entry, dn, updated_attributes}
    updated_state = [List.first(state), updated_eldap_entry]

    {:reply, :ok, updated_state}
  end

  def open(_hosts, _options) do
    __MODULE__
    |> Process.whereis()
    |> case do
      nil -> GenServer.start_link(__MODULE__, [], name: __MODULE__)
      pid -> {:ok, pid}
    end
  end

  def simple_bind(_pid, 'uid=sample_user,ou=users,dc=example,dc=com', 'password'), do: :ok
  def simple_bind(_, _, _), do: {:error, :invalidCredentials}

  def close(_pid) do
    :ok
  end
end
