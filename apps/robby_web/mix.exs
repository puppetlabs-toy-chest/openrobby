defmodule RobbyWeb.Mixfile do
  use Mix.Project

  def project do
    [
      app: :robby_web,
      version: get_version(),
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.1",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      dialyzer: [
        plt_add_deps: true,
        plt_file: ".local.plt",
        flags: []
      ],
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: {RobbyWeb, []},
      applications: [
        :phoenix,
        :phoenix_html,
        :cowboy,
        :logger,
        :gettext,
        :bbmustache,
        :erlware_commons,
        :exactor,
        :getopt,
        :ibrowse,
        :providers,
        :phoenix_ecto,
        :postgrex,
        :con_cache,
        :eldap,
        :earmark,
        :conform,
        :mailman,
        :eiconv,
        :observer,
        :runtime_tools,
        :logger_file_backend,
        :db_connection,
        :ldap_search,
        :ldap_write,
        :sms_code,
        :ecto_ldap,
        :timex_ecto,
        :sweet_xml,
        :timex,
        :tzdata,
        :httpoison,
        :mogrify,
        :ex_aws,
        :ex_aws_s3
      ]
    ]
  end

  defp get_version do
    case System.cmd("git", ["describe", "--always", "--tags"]) do
      {output, 0} -> String.trim(output)
    end
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [
      {:phoenix, "~> 1.3"},
      {:phoenix_ecto, "~> 3.3"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.1", only: :dev},
      {:postgrex, "~> 0.13"},
      {:ecto, "~> 2.2"},
      {:cowboy, "~> 1.0"},
      {:gettext, "~> 0.14"},
      {:con_cache, "~> 0.12.1"},
      {:logger_file_backend, "~> 0.0.10"},
      {:mailman, "~> 0.3"},
      # this dependency of mailman isn't tracked down for some reason
      {:eiconv, github: "zotonic/eiconv", override: true},
      {:distillery, "~> 1.5", runtime: false},
      {:conform, "~> 2.5"},
      {:ldap_search, in_umbrella: true},
      {:ldap_write, in_umbrella: true},
      {:sms_code, in_umbrella: true},
      {:ecto_ldap, "~> 0.4"},
      {:timex, "~> 3.1"},
      {:timex_ecto, "~> 3.2"},
      {:plug, "~> 1.4"},
      {:dialyxir, "~> 0.5", only: :dev},
      {:poison, "~> 3.1", override: true},
      {:erlware_commons, "~> 1.0"},
      {:getopt, "~> 1.0"},
      {:bbmustache, "~> 1.5"},
      {:providers, "~> 1.7"},
      {:mogrify, "~> 0.5"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"}
    ]
  end
end
