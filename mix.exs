defmodule CONREC.MixProject do
  use Mix.Project

  def project do
    [
      app: :conrex,
      description: description(),
      package: package(),
      version: "1.0.0",
      elixir: "~> 1.9",
      deps: deps(),
      source_url: "https://github.com/NAISorg/conrex/"
    ]
  end

  defp description() do
    """
    An implementation of the CONREC contouring algorithm, described at
    <http://paulbourke.net/papers/conrec/>.
    """
  end

  defp package() do
    %{
      name: "conrex",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/NAISorg/conrex/"}
    }
  end

  defp deps do
    [
      {:geo, "~> 3.1"},
      {:topo, "~> 0.4.0"},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
    ]
  end
end
