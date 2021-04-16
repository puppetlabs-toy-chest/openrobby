defmodule LdapWrapper.Ldap.Sandbox do
  use GenServer

  # CLIENT
  def open(_hosts, _options) do
    GenServer.start_link(__MODULE__, [])
  end

  def close(handle) do
    GenServer.call(handle, :close)
  end

  def simple_bind(handle, dn, password) do
    GenServer.call(handle, {:simple_bind, dn, password})
  end

  # hard coded to search by email
  def search(handle, [{:base, _}, {:filter, {:equalityMatch, 'mail', email}}, {:attributes, _}]) do
    GenServer.call(handle, {:search, email}, 10000)
  end

  def equalityMatch(type, value) do
    send self(), {:equalityMatch, type, value}
    {:equalityMatch, type, value}
  end

  def modify_password(_handle, dn, new_password) do
    send self(), {:modify_password, dn, new_password}
    :ok
  end

  def modify_password(_handle, dn, new_password, old_password) do
    send self(), {:modify_password, dn, new_password, old_password}
    :ok
  end

  # SERVER STUFF

  def init([]) do
    fake_db = [
      %{email: 'tom@example.com',
        password: 'cattbutt',
        dn: 'uid=tom,ou=users,dc=example,dc=com',
        ldap_search_result:
        [{:eldap_entry,
            'uid=tom,ou=users,dc=example,dc=com',
            [{'uid', ['tom']},
             {'objectClass',['inetOrgPerson', 'posixAccount', 'shadowAccount', 'organizationalPerson', 'person', 'top', 'orgPerson']},
             {'mail', ['tom@example.com']}
            ]
        }]
      },
      %{email: 'jim@example.com',
        password:  '12345678901234567890qwertyuioqwertyuio!🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀blastoffi have impossibly long passwords hahaha',
        dn: 'uid=jim,ou=users,dc=example,dc=com',
        ldap_search_result:
        [{:eldap_entry, 'uid=jim,ou=users,dc=example,dc=com',
          [{'uid', ['jim']},
           {'objectClass',['inetOrgPerson', 'posixAccount', 'shadowAccount', 'organizationalPerson','person', 'top', 'orgPerson']},
           {'mail', ['jim@example.com']},
           {'mobile', ['5035555555']}
          ]
        }]
      },
      %{email: 'jane@example.com',
        password: 'ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg',
        dn: 'uid=jane,ou=users,dc=example,dc=com',
        ldap_search_result:
          [{:eldap_entry, 'uid=jane,ou=users,dc=example,dc=com',
            [{'uid', ['jane']},
             {'objectClass', ['inetOrgPerson', 'posixAccount', 'shadowAccount', 'organizationalPerson', 'person', 'top', 'orgPerson']},
             {'mail', ['jane@example.com']}
             ]
           }]
      },
      %{email: nil,
        password: 'password',
        dn: 'cn=internal-password-reset,ou=service,ou=users,dc=example,dc=com',
        ldap_search_result:
          [{:eldap_entry, 'cn=internal-password-reset,ou=service,ou=users,dc=example,dc=com',
            [{'uid', ['internal-password-reset']},
             {'objectClass', ['inetOrgPerson', 'posixAccount', 'shadowAccount', 'organizationalPerson', 'person', 'top', 'orgPerson']},
             {'mail', []}
             ]
           }]
      }
    ]
    {:ok, fake_db}
  end

  def handle_call({:simple_bind, dn, password}, _from, fake_db) do
    Enum.filter(fake_db, fn entry -> entry[:dn] == dn end)
    |> case do
      [%{password: ^password, dn: ^dn}] -> {:reply, :ok, fake_db}
      _ -> {:reply, {:error, :invalidCredentials}, fake_db}
    end
  end

  def handle_call({:search, email}, _from, fake_db) do
    search_result =
      fake_db
      |> Enum.filter(fn entry -> entry[:email] == email end)
      |> case do
        [%{email: ^email, ldap_search_result: ldap_search_result}] -> ldap_search_result
        _ -> []
      end
    {:reply, {:ok, {:eldap_search_result, search_result, []}}, fake_db }
  end

  def handle_call(:close, _from, fake_db) do
    :ok = terminate(:close, fake_db)
    {:reply, :ok, fake_db}
  end
end
