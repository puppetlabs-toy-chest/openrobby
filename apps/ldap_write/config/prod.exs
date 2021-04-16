use Mix.Config

config :ldap_write,
  hosts: ["ldap.example.com"],
  port: 636,
  use_ssl: true,
  write_dn: "cn=internal-password-reset,ou=service,ou=users,dc=example,dc=com",
  write_password: "not my real password"
