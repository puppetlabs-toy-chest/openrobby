use Mix.Config

config :ldap_search,
  hosts: ["ldap.example.com"],
  port: 636,
  use_ssl: true,
  base_rdn: "ou=users,dc=example,dc=com",
  read_dn: "uid=jim,ou=users,dc=example,dc=com",
  read_password: "not my real password"
