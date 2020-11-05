defmodule CONREC.MixProject do
  use Mix.Project

  def project do
    [
      app: :conrex,
      description: description(),
      version: "1.0.0",
      licenses: ["MIT"],
      elixir: "~> 1.9",
      deps: deps()
    ]
  end

  defp description() do
    """
    An implementation of the CONREC contouring algorithm, described at
    <http://paulbourke.net/papers/conrec/>.
    """
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
