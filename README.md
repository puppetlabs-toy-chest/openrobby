# Robby3

Robby does a few things:

  * Displays a company directory with employee names, photos, who they report
    to, and what to bribe them with.
  * Displays office maps, including the remote office.
  * Allows users to change their profile picture and adjust their t-shirt size.
  * Allows users to change their password, even if they've forgotten it.
  * Provides light entertainment and facial recognition training through the
    “Who is that?” game.
  * Chat*

## Requirements

  * Erlang 18+ (20 works fine)
  * Elixir 1.5 (1.4 may work)
  * npm
  * PostgreSQL

On macOS, those can be installed with `brew`:

~~~
brew install elixir npm postgresql
brew services start postgresql
~~~

## Running locally
Robby is an Elixir application. You'll need Erlang, Elixir, and npm installed to
build it. Erlang 20.1.7 and Elixir 1.5.2 are known to work.

~~~
# Make a copy of the sample dev config
cp apps/robby_web/config/dev.exs.sample apps/robby_web/config/dev.exs

# Set two environment variables for your LDAP credentials.
export ROBBY_LDAP_USERNAME=john.doe
export ROBBY_LDAP_PASSWORD=w0uldnty0u1iketoknow

# Create the Postgres database
createdb robby_web_dev

# Download all dependencies
mix deps.get

mix compile

# Build the CSS and JavaScript assets with Node.js's brunch package
cd apps/robby_web
npm install
$(npm bin)/brunch build
cd ../..

# Start the web server. It will run on http://localhost:4000
mix phx.server
~~~

Most changes to the application code will be loaded into the running application
immediately.

## Versions

The application uses [`git describe --tags`](git-describe) to generate a unique
version for every commit. This produces versions like "1.1.1-7-g612036c". The
format is TAG-COUNT-gHASH.

  * TAG is the last tag found in the repo. In this case the last release that
    was tagged was 1.1.1.
  * COUNT is the number of commits since that tag. There were 7 commits sine
    1.1.1 was tagged.
  * HASH is the first 7 characters of the commit hash. This makes it easier to
    find exactly what code went into a build.

If the current revision is tagged, then the version format will just contain the
tag, e.g. "1.1.1".

----
_* It's a secret._

[git-describe]: https://www.git-scm.com/docs/git-describe
