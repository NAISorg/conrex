defmodule Conrex.ContourBuilderTest do
  use ExUnit.Case
  alias Conrex.ContourBuilder

  test "it builds rings from a segment list" do
    rings = ContourBuilder.build_rings([
      {{0, 0}, {0, 1}},
      {{3, 6}, {2, 5}},
      {{1, 1}, {0, 0}},
      {{2, 5}, {2, 6}},
      {{0, 1}, {1, 1}},
      {{2, 6}, {3, 6}}
    ])
    assert rings == [
      [{3, 6}, {2, 5}, {2, 6}, {3, 6}],
      [{1, 1}, {0, 0}, {0, 1}, {1, 1}]
    ]
  end
end
