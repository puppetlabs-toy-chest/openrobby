# Robby Test Notes

## How to Run Tests

To run this test suite, you must be in the web application project root, then execute this command:
```bash
  # robby3/apps/robby_web
  $ mix test
```

## External Service Stubs

There are two external service stubs currently implemented in Robby for the purposes of testing.
  * LDAP Sandbox
  * AWS S3 Sandbox

These two modules stub out service responses when given a particular configuration of method parameters.

## Test Environment Configuration

In order to ensure the test runs use the correct stub implementation, external services must be provided
to each module based on a configurable setting.  This is done by specifying an adapter in Robby's config
files which points to either a live version of the service or the stub implementation.

```elixir
###################
# In config/dev.exs

config :robby_web, RobbyWeb.LdapRepo,
  adapter: Ecto.Ldap.Adapter,
  # ...

config :ex_aws,
  s3_adapter: ExAws.S3,
  # ...


####################
# In config/test.exs

config :robby_web, RobbyWeb.LdapRepo,
  adapter: RobbyWeb.Ldap.Adapter.Sandbox
  # ...

config :ex_aws,
  s3_adapter: RobbyWeb.ExAws.S3.Sandbox,
  # ...
```

## Test Todo List

Nothing here!
