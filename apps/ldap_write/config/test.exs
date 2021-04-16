use Mix.Config

config :ldap_write,
  ldap_api: LdapWrapper.Ldap.Sandbox,
  hosts: ["ldap1-test.ops.example.net"],
  port: 636,
  use_ssl: true,
  write_dn: "cn=internal-password-reset,ou=service,ou=users,dc=example,dc=com",
  write_password: "password"
  
config :ldap_wrapper, ldap_api: LdapWrapper.Ldap.Sandbox
