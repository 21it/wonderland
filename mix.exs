defmodule Wonderland.MixProject do
  use Mix.Project

  def project do
    [
      app: :wonderland,
      version: "VERSION" |> File.read!() |> String.trim(),
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      # excoveralls
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.travis": :test,
        "coveralls.circle": :test,
        "coveralls.semaphore": :test,
        "coveralls.post": :test,
        "coveralls.detail": :test,
        "coveralls.html": :test
      ],
      # dialyxir
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore",
        plt_add_apps: [
          :mix,
          :ex_unit
        ]
      ],
      # ex_doc
      name: "Wonderland",
      source_url: "https://github.com/tkachuk-labs/wonderland",
      homepage_url: "https://github.com/tkachuk-labs/wonderland",
      docs: [main: "readme", extras: ["README.md"]],
      # hex.pm stuff
      description: "Elixir functional programming foundation",
      package: [
        licenses: ["MIT"],
        files: ["lib", "priv", "mix.exs", "README*", "VERSION*"],
        maintainers: ["tkachuk.labs@gmail.com"],
        links: %{
          "GitHub" => "https://github.com/tkachuk-labs/wonderland",
          "Author's home page" => "https://tkachuklabs.com"
        }
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:calculus, "~> 0.3"},
      {:kare, "~> 1.0"},
      # test tools
      {:propcheck, "~> 1.2", only: :test},
      # development tools
      {:excoveralls, "~> 0.8", runtime: false},
      {:dialyxir, "~> 0.5", runtime: false},
      {:ex_doc, "~> 0.19", runtime: false},
      {:credo, "~> 0.9", runtime: false},
      {:boilex, "~> 0.2", runtime: false}
    ]
  end

  defp aliases do
    [
      docs: [
        "docs",
        "cmd mkdir -p doc/priv/img/",
        "cmd cp -R priv/img/ doc/priv/img/",
        "docs"
      ]
    ]
  end
end
