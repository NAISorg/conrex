defmodule Conrex.CONREC do
  @moduledoc false

  # values is a 2d array of "heights"; contour_levels a list of height values to contour at
  def conrec(values, x_coords, y_coords, contour_levels) do
    Enum.reduce(contour_levels, %{}, fn contour_level, contours ->
      # iterate over each cell of 2x2 coordinates
      segments = Enum.reduce(0..(length(x_coords) - 2), [], fn i, segments ->
        row_segments = Enum.reduce(0..(length(y_coords) - 2), [], fn j, row_segments ->
          cell = cell_at(values, x_coords, y_coords, i, j)
          if cell_has_segments?(cell, contour_level) do
            segments = cell_segments(cell, contour_level)
            List.flatten([segments | row_segments])
          else
            row_segments
          end
        end)
        List.flatten([row_segments | segments])
      end)
      Map.put(contours, contour_level, segments)
    end)
  end

  # gets a cell at x, y in a grid
  defp cell_at(values, x_coords, y_coords, x, y) do
    v1 = vertex_at(values, x_coords, y_coords, x, y)
    v2 = vertex_at(values, x_coords, y_coords, x+1, y)
    v3 = vertex_at(values, x_coords, y_coords, x+1, y+1)
    v4 = vertex_at(values, x_coords, y_coords, x, y+1)

    [ v1, v2, v3, v4 ] # arranged clockwise
  end

  # finds a vertex in a grid
  defp vertex_at(values, x_coords, y_coords, x, y) do
    x_coord = Enum.at(x_coords, x)
    y_coord = Enum.at(y_coords, y)
    value = Enum.at(Enum.at(values, x), y)
    {x_coord, y_coord, value}
  end

  # gets all segments for a cell
  defp cell_segments(cell, level) do
    tris = cell_to_tris(cell)
    Enum.map(tris, fn triangle -> get_segment(triangle, level) end)
      |> Enum.filter(fn triangle -> triangle != :nil end)
  end

  defp cell_has_segments?(cell, level), do: level > cell_min(cell) and level < cell_max(cell)

  defp cell_max(cell) do
    { _x, _y, h } = Enum.max_by(cell, fn { _x, _y, h } -> h end)
    h
  end

  defp cell_min(cell) do
    { _x, _y, h } = Enum.min_by(cell, fn { _x, _y, h } -> h end)
    h
  end

  defp cell_to_tris([ v1, v2, v3, v4 ] = cell) do
    # center vertex is average of corners
    center = cell_center(cell)

    [
      { v1, v2, center },
      { v2, v3, center },
      { v3, v4, center },
      { v1, v4, center }
    ]
  end

  defp cell_center(cell) do
    num_verts = length(cell)
    cell
      |> Enum.reduce({ 0, 0, 0 }, fn { x, y, h }, { cx, cy, ch } -> { cx + x, cy + y, ch + h } end)
      |> (fn { x, y, h } -> { x / num_verts, y / num_verts, h / num_verts } end).()
  end

  def get_segment({ v1, v2, v3 } = triangle, level) do
    case segment_position(triangle, level) do
      # pathological case
      { :on, :on, :on } -> :nil

      # segment between two vertices
      { :on, :on, _ } -> { point(v1), point(v2) }
      { :on, _, :on } -> { point(v1), point(v3) }
      { _, :on, :on } -> { point(v2), point(v3) }

      # segment from one vertex to opposite side
      { :on, :above, :below } -> { point(v1), intersect(v2, v3, level) }
      { :on, :below, :above } -> { point(v1), intersect(v2, v3, level) }
      { :above, :on, :below } -> { point(v2), intersect(v1, v3, level) }
      { :below, :on, :above } -> { point(v2), intersect(v1, v3, level) }
      { :above, :below, :on } -> { point(v3), intersect(v1, v2, level) }
      { :below, :above, :on } -> { point(v3), intersect(v1, v2, level) }

      # segment from one side to another side
      { :below, :above, :above } -> { intersect(v1, v2, level), intersect(v1, v3, level) }
      { :above, :below, :below } -> { intersect(v1, v2, level), intersect(v1, v3, level) }
      { :above, :below, :above } -> { intersect(v1, v2, level), intersect(v2, v3, level) }
      { :below, :above, :below } -> { intersect(v1, v2, level), intersect(v2, v3, level) }
      { :above, :above, :below } -> { intersect(v1, v3, level), intersect(v2, v3, level) }
      { :below, :below, :above } -> { intersect(v1, v3, level), intersect(v2, v3, level) }

      # no segment
      _ -> :nil
    end
  end

  defp segment_position({ v1, v2, v3 }, level) do
    { vertex_position(v1, level), vertex_position(v2, level), vertex_position(v3, level) }
  end

  defp vertex_position({ _x, _y, h }, level) when h < level, do: :below
  defp vertex_position({ _x, _y, h }, level) when h == level, do: :on
  defp vertex_position({ _x, _y, h }, level) when h > level, do: :above

  defp intersect({ x1, y1, h1 }, { x2, y2, h2 }, level) do
    d1 = h1 - level
    d2 = h2 - level
    x = (d2*x1 - d1*x2) / (d2 - d1)
    y = (d2*y1 - d1*y2) / (d2 - d1)
    { x, y }
  end

  defp point({ x, y, _h }), do: { x, y }

end
