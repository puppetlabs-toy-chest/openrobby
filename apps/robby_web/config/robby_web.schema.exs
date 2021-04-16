@moduledoc """
A schema is a keyword list which represents how to map, transform, and validate
configuration values parsed from the .conf file. The following is an explanation of
each key in the schema definition in order of appearance, and how to use them.

## Import

A list of application names (as atoms), which represent apps to load modules from
which you can then reference in your schema definition. This is how you import your
own custom Validator/Transform modules, or general utility modules for use in
validator/transform functions in the schema. For example, if you have an application
`:foo` which contains a custom Transform module, you would add it to your schema like so:

`[ import: [:foo], ..., transforms: ["myapp.some.setting": MyApp.SomeTransform]]`

## Extends

A list of application names (as atoms), which contain schemas that you want to extend
with this schema. By extending a schema, you effectively re-use definitions in the
extended schema. You may also override definitions from the extended schema by redefining them
in the extending schema. You use `:extends` like so:

`[ extends: [:foo], ... ]`

## Mappings

Mappings define how to interpret settings in the .conf when they are translated to
runtime configuration. They also define how the .conf will be generated, things like
documention, @see references, example values, etc.

See the moduledoc for `Conform.Schema.Mapping` for more details.

## Transforms

Transforms are custom functions which are executed to build the value which will be
stored at the path defined by the key. Transforms have access to the current config
state via the `Conform.Conf` module, and can use that to build complex configuration
from a combination of other config values.

See the moduledoc for `Conform.Schema.Transform` for more details and examples.

## Validators

Validators are simple functions which take two arguments, the value to be validated,
and arguments provided to the validator (used only by custom validators). A validator
checks the value, and returns `:ok` if it is valid, `{:warn, message}` if it is valid,
but should be brought to the users attention, or `{:error, message}` if it is invalid.

See the moduledoc for `Conform.Schema.Validator` for more details and examples.
"""
[
  extends: [],
  import: [],
  mappings: [
    "logger.console.format": [
      commented: false,
      datatype: :binary,
      default: """
      $time $metadata[$level] $message
      """,
      doc: "Provide documentation for logger.console.format here.",
      hidden: false,
      to: "logger.console.format"
    ],
    "logger.console.metadata": [
      commented: false,
      datatype: [
        list: :atom
      ],
      default: [
        :request_id
      ],
      doc: "Provide documentation for logger.console.metadata here.",
      hidden: false,
      to: "logger.console.metadata"
    ],
    "logger.backends": [
      commented: false,
      datatype: [
        list: :atom
      ],
      default: [
        :console
      ],
      doc: "Provide documentation for logger.backends here.",
      hidden: false,
      to: "logger.backends"
    ],
    "logger.level": [
      commented: false,
      datatype: :atom,
      default: :info,
      doc: "Provide documentation for logger.level here.",
      hidden: false,
      to: "logger.level"
    ],
    "logger.info.path": [
      commented: false,
      datatype: :binary,
      default: "/var/log/robby3/info.log",
      doc: "Provide documentation for logger.info.path here.",
      hidden: false,
      to: "logger.info.path"
    ],
    "logger.info.level": [
      commented: false,
      datatype: :atom,
      default: :info,
      doc: "Provide documentation for logger.info.level here.",
      hidden: false,
      to: "logger.info.level"
    ],
    "logger.error.path": [
      commented: false,
      datatype: :binary,
      default: "/var/log/robby3/error.log",
      doc: "Provide documentation for logger.error.path here.",
      hidden: false,
      to: "logger.error.path"
    ],
    "logger.error.level": [
      commented: false,
      datatype: :atom,
      default: :error,
      doc: "Provide documentation for logger.error.level here.",
      hidden: false,
      to: "logger.error.level"
    ],
    "robby_web.Elixir.RobbyWeb.Emailer.server": [
      commented: false,
      datatype: :binary,
      default: "smtp.sendgrid.net",
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Emailer.server here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Emailer.server"
    ],
    "robby_web.Elixir.RobbyWeb.Emailer.port": [
      commented: false,
      datatype: :integer,
      default: 587,
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Emailer.port here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Emailer.port"
    ],
    "robby_web.Elixir.RobbyWeb.Emailer.username": [
      commented: false,
      datatype: :binary,
      default: "not real user",
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Emailer.username here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Emailer.username"
    ],
    "robby_web.Elixir.RobbyWeb.Emailer.password": [
      commented: false,
      datatype: :binary,
      default: "not real password",
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Emailer.password here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Emailer.password"
    ],
    "robby_web.Elixir.RobbyWeb.Emailer.ssl": [
      commented: false,
      datatype: :atom,
      default: false,
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Emailer.ssl here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Emailer.ssl"
    ],
    "robby_web.Elixir.RobbyWeb.Emailer.tls": [
      commented: false,
      datatype: :atom,
      default: :always,
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Emailer.tls here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Emailer.tls"
    ],
    "robby_web.Elixir.RobbyWeb.Emailer.auth": [
      commented: false,
      datatype: :atom,
      default: :always,
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Emailer.auth here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Emailer.auth"
    ],
    "robby_web.Elixir.RobbyWeb.Endpoint.root": [
      commented: false,
      datatype: :binary,
      default: "/opt/robby/apps/robby_web",
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Endpoint.root here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Endpoint.root"
    ],
    "robby_web.Elixir.RobbyWeb.Endpoint.render_errors.accepts": [
      commented: false,
      datatype: [
        list: :binary
      ],
      default: [
        "html",
        "json"
      ],
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Endpoint.render_errors.accepts here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Endpoint.render_errors.accepts"
    ],
    "robby_web.Elixir.RobbyWeb.Endpoint.pubsub.name": [
      commented: false,
      datatype: :atom,
      default: RobbyWeb.PubSub,
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Endpoint.pubsub.name here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Endpoint.pubsub.name"
    ],
    "robby_web.Elixir.RobbyWeb.Endpoint.pubsub.adapter": [
      commented: false,
      datatype: :atom,
      default: Phoenix.PubSub.PG2,
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Endpoint.pubsub.adapter here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Endpoint.pubsub.adapter"
    ],
    "robby_web.Elixir.RobbyWeb.Endpoint.http.port": [
      commented: false,
      datatype: :integer,
      default: 8000,
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Endpoint.http.port here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Endpoint.http.port"
    ],
    "robby_web.Elixir.RobbyWeb.Endpoint.url.host": [
      commented: false,
      datatype: :binary,
      default: "example.com",
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Endpoint.url.host here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Endpoint.url.host"
    ],
    "robby_web.Elixir.RobbyWeb.Endpoint.url.port": [
      commented: false,
      datatype: :integer,
      default: 80,
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Endpoint.url.port here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Endpoint.url.port"
    ],
    "robby_web.Elixir.RobbyWeb.Endpoint.url.scheme": [
      commented: false,
      datatype: :binary,
      default: "http",
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Endpoint.url.scheme here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Endpoint.url.scheme"
    ],
    "robby_web.Elixir.RobbyWeb.Endpoint.cache_static_manifest": [
      commented: false,
      datatype: :binary,
      default: "priv/static/manifest.json",
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Endpoint.cache_static_manifest here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Endpoint.cache_static_manifest"
    ],
    "robby_web.Elixir.RobbyWeb.Endpoint.server": [
      commented: false,
      datatype: :atom,
      default: true,
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Endpoint.server here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Endpoint.server"
    ],
    "robby_web.Elixir.RobbyWeb.Endpoint.secret_key_base": [
      commented: false,
      datatype: :binary,
      default: "your secret key hash",
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Endpoint.secret_key_base here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Endpoint.secret_key_base"
    ],
    "robby_web.Elixir.RobbyWeb.Repo.adapter": [
      commented: false,
      datatype: :atom,
      default: Ecto.Adapters.Postgres,
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Repo.adapter here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Repo.adapter"
    ],
    "robby_web.Elixir.RobbyWeb.Repo.username": [
      commented: false,
      datatype: :binary,
      default: "jim",
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Repo.username here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Repo.username"
    ],
    "robby_web.Elixir.RobbyWeb.Repo.password": [
      commented: false,
      datatype: :binary,
      default: "postgres",
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Repo.password here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Repo.password"
    ],
    "robby_web.Elixir.RobbyWeb.Repo.database": [
      commented: false,
      datatype: :binary,
      default: "robby_web_prod",
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Repo.database here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Repo.database"
    ],
    "robby_web.Elixir.RobbyWeb.Repo.pool_size": [
      commented: false,
      datatype: :integer,
      default: 20,
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.Repo.pool_size here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.Repo.pool_size"
    ],
    "robby_web.Elixir.RobbyWeb.LdapRepo.adapter": [
      commented: false,
      datatype: :atom,
      default: Ecto.Ldap.Adapter,
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.LdapRepo.adapter here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.LdapRepo.adapter"
    ],
    "robby_web.Elixir.RobbyWeb.LdapRepo.hostname": [
      commented: false,
      datatype: :binary,
      default: "ldap.example.com",
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.LdapRepo.hostname here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.LdapRepo.hostname"
    ],
    "robby_web.Elixir.RobbyWeb.LdapRepo.base": [
      commented: false,
      datatype: :binary,
      default: "dc=example,dc=com",
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.LdapRepo.base here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.LdapRepo.base"
    ],
    "robby_web.Elixir.RobbyWeb.LdapRepo.port": [
      commented: false,
      datatype: :integer,
      default: 636,
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.LdapRepo.port here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.LdapRepo.port"
    ],
    "robby_web.Elixir.RobbyWeb.LdapRepo.ssl": [
      commented: false,
      datatype: :atom,
      default: true,
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.LdapRepo.ssl here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.LdapRepo.ssl"
    ],
    "robby_web.Elixir.RobbyWeb.LdapRepo.user_dn": [
      commented: false,
      datatype: :binary,
      default: "CHANGE_USER_DN",
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.LdapRepo.user_dn here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.LdapRepo.user_dn"
    ],
    "robby_web.Elixir.RobbyWeb.LdapRepo.password": [
      commented: false,
      datatype: :binary,
      default: "CHANGE_PASSWORD",
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.LdapRepo.password here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.LdapRepo.password"
    ],
    "robby_web.Elixir.RobbyWeb.LdapRepo.pool_size": [
      commented: false,
      datatype: :integer,
      default: 1,
      doc: "Provide documentation for robby_web.Elixir.RobbyWeb.LdapRepo.pool_size here.",
      hidden: false,
      to: "robby_web.Elixir.RobbyWeb.LdapRepo.pool_size"
    ],
    "phoenix.generators.migration": [
      commented: false,
      datatype: :atom,
      default: true,
      doc: "Provide documentation for phoenix.generators.migration here.",
      hidden: false,
      to: "phoenix.generators.migration"
    ],
    "phoenix.generators.binary_id": [
      commented: false,
      datatype: :atom,
      default: false,
      doc: "Provide documentation for phoenix.generators.binary_id here.",
      hidden: false,
      to: "phoenix.generators.binary_id"
    ],
    "ldap_wrapper.ldap_api": [
      commented: false,
      datatype: :atom,
      default: :eldap,
      doc: "Provide documentation for ldap_wrapper.ldap_api here.",
      hidden: false,
      to: "ldap_wrapper.ldap_api"
    ],
    "ldap_write.hosts": [
      commented: false,
      datatype: [
        list: :binary
      ],
      default: [
        "ldap.example.com"
      ],
      doc: "Provide documentation for ldap_write.hosts here.",
      hidden: false,
      to: "ldap_write.hosts"
    ],
    "ldap_write.port": [
      commented: false,
      datatype: :integer,
      default: 636,
      doc: "Provide documentation for ldap_write.port here.",
      hidden: false,
      to: "ldap_write.port"
    ],
    "ldap_write.use_ssl": [
      commented: false,
      datatype: :atom,
      default: true,
      doc: "Provide documentation for ldap_write.use_ssl here.",
      hidden: false,
      to: "ldap_write.use_ssl"
    ],
    "ldap_write.write_dn": [
      commented: false,
      datatype: :binary,
      default: "cn=internal-password-reset,ou=service,ou=users,dc=example,dc=com",
      doc: "Provide documentation for ldap_write.write_dn here.",
      hidden: false,
      to: "ldap_write.write_dn"
    ],
    "ldap_write.write_password": [
      commented: false,
      datatype: :binary,
      default: "not my real password",
      doc: "Provide documentation for ldap_write.write_password here.",
      hidden: false,
      to: "ldap_write.write_password"
    ],
    "ldap_search.hosts": [
      commented: false,
      datatype: [
        list: :binary
      ],
      default: [
        "ldap.example.com"
      ],
      doc: "Provide documentation for ldap_search.hosts here.",
      hidden: false,
      to: "ldap_search.hosts"
    ],
    "ldap_search.port": [
      commented: false,
      datatype: :integer,
      default: 636,
      doc: "Provide documentation for ldap_search.port here.",
      hidden: false,
      to: "ldap_search.port"
    ],
    "ldap_search.use_ssl": [
      commented: false,
      datatype: :atom,
      default: true,
      doc: "Provide documentation for ldap_search.use_ssl here.",
      hidden: false,
      to: "ldap_search.use_ssl"
    ],
    "ldap_search.base_rdn": [
      commented: false,
      datatype: :binary,
      default: "ou=users,dc=example,dc=com",
      doc: "Provide documentation for ldap_search.base_rdn here.",
      hidden: false,
      to: "ldap_search.base_rdn"
    ],
    "ldap_search.read_dn": [
      commented: false,
      datatype: :binary,
      default: "uid=jim,ou=users,dc=example,dc=com",
      doc: "Provide documentation for ldap_search.read_dn here.",
      hidden: false,
      to: "ldap_search.read_dn"
    ],
    "ldap_search.read_password": [
      commented: false,
      datatype: :binary,
      default: "not my real password",
      doc: "Provide documentation for ldap_search.read_password here.",
      hidden: false,
      to: "ldap_search.read_password"
    ],
    "sms_code.twilio_api": [
      commented: false,
      datatype: :atom,
      default: ExTwilio,
      doc: "Provide documentation for sms_code.twilio_api here.",
      hidden: false,
      to: "sms_code.twilio_api"
    ],
    "ex_twilio.account_sid": [
      commented: false,
      datatype: :binary,
      default: "twilio account SID",
      doc: "Provide documentation for ex_twilio.account_sid here.",
      hidden: false,
      to: "ex_twilio.account_sid"
    ],
    "ex_twilio.auth_token": [
      commented: false,
      datatype: :binary,
      default: "fake token",
      doc: "Provide documentation for ex_twilio.auth_token here.",
      hidden: false,
      to: "ex_twilio.auth_token"
    ],
    "ex_aws.adapter": [
      commented: false,
      datatype: :atom,
      default: ExAws,
      doc: "ExAws Adapter",
      hidden: false,
      to: "ex_aws.adapter"
    ],
    "ex_aws.s3_adapter": [
      commented: false,
      datatype: :atom,
      default: ExAws.S3,
      doc: "ExAws S3 Adapter",
      hidden: false,
      to: "ex_aws.s3_adapter"
    ],
    "ex_aws.access_key_id": [
      commented: false,
      datatype: :binary,
      default: "ACCESS_KEY_ID",
      doc: "ExAws access key id",
      hidden: false,
      to: "ex_aws.access_key_id"
    ],
    "ex_aws.secret_access_key": [
      commented: false,
      datatype: :binary,
      default: "SECRET_ACCESS_KEY",
      doc: "ExAws secret access key",
      hidden: false,
      to: "ex_aws.secret_access_key"
    ],
    "ex_aws.region": [
      commented: false,
      datatype: :binary,
      default: "us-west-2",
      doc: "ExAws region",
      hidden: false,
      to: "ex_aws.region"
    ]
  ],
  transforms: [],
  validators: []
]
