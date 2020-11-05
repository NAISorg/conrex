defmodule Conrex do
  @moduledoc """
  Implements the CONREC contouring algorithm

  See <http://paulbourke.net/papers/conrec/> for details on the algorithm.
  """

  alias Conrex.CONREC
  alias Conrex.ContourBuilder
  alias Conrex.PolygonBuilder

  @doc """
  Implements CONREC

  Given a 2D array of "height" values, a list of X and Y coordinates, and a list
  of contour levels to generate, this will output a list of line segments (with
  coordinates interpolated from the given X and Y coordinate array values).
  """
  defdelegate conrec(values, x_coords, y_coords, contour_levels), to: CONREC

  @doc """
  Generates contours with `conrec`, and formats each contour as a `%Geo.Polygon{}`

  The polygons for each level are calculated with respect to a given reference
  point that is known to lie within the polygon (but not within any holes).
  """
  def contour_polygons(values, x_coords, y_coords, contour_levels, reference_point) do
    conrec(values, x_coords, y_coords, contour_levels)
    |> Enum.map(fn {level, contour_segments} ->
      polygons = contour_segments
        |> ContourBuilder.build_rings()
        |> PolygonBuilder.build_polygon(reference_point)
      {level, polygons}
    end)
  end

end
