defmodule LdapSearch.Mixfile do
  use Mix.Project

  def project do
    [app: :ldap_search,
     version: get_version(),
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :poolboy, :ssl, :eldap, :ldap_wrapper, :conform],
     mod: {LdapSearch, []}]
  end

  defp get_version do
    case System.cmd("git", ["describe", "--always", "--tags"]) do
      {output, 0} -> String.trim(output)
    end
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [ {:ldap_wrapper, in_umbrella: true},
      {:distillery, "~> 1.5", runtime: false},
      {:conform, "~> 2.0"},
      {:poolboy, "~> 1.5"},
      {:erlware_commons, "~> 1.0"},
    ]
  end
end
