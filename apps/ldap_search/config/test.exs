use Mix.Config

config :ldap_search,
  ldap_api: LdapWrapper.Ldap.Sandbox,
  hosts: ["ldap1-test.ops.example.net"],
  port: 636,
  use_ssl: true,
  base_rdn: "ou=users,dc=example,dc=com",
  read_dn: "cn=internal-password-reset,ou=service,ou=users,dc=example,dc=com",
  read_password: "password"

config :ldap_wrapper, ldap_api: LdapWrapper.Ldap.Sandbox
