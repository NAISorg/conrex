defmodule Conrex.PolygonBuilder do
  @moduledoc false

  # WGS84
  @default_srid 4326

  @typep point :: {number, number}
  @typep segment :: {point, point}

  @spec build_polygon([segment], point) :: [segment]
  def build_polygon(rings, reference_point) do
    normalize_rings(rings, reference_point)
    |> format_coordinates()
    |> format_polygon()
  end

  defp format_polygon(coordinates) do
    %Geo.Polygon{
      coordinates: coordinates,
      srid: @default_srid
    }
  end

  defp format_coordinates(rings) do
    Enum.map(rings, fn coord_list ->
      Enum.map(coord_list, fn {x, y} -> {Float.round(x, 6), Float.round(y, 6)} end)
    end)
  end

  defp normalize_rings(rings, origin) do
    if Enum.count(rings) == 1 do
      ring = check_winding(List.first(rings), :ccw)
      [ring]
    else
      main_ring = rings
        |> Enum.find(fn ring -> point_in_polygon(origin, ring) end)
        |> check_winding(:ccw)

      holes = rings
        |> Enum.filter(fn ring -> !point_in_polygon(origin, ring) and polygon_in_polygon(ring, main_ring) end)
        |> Enum.map(fn ring -> check_winding(ring, :cw) end)

      [main_ring | holes]
    end
  end

  defp point_in_polygon({x, y}, coords) do
    point = %Geo.Point{coordinates: {x, y}}
    polygon = %Geo.Polygon{coordinates: [coords]}
    Topo.contains?(polygon, point)
  end

  defp polygon_in_polygon(coords_a, coords_b) do
    polygon_a = %Geo.Polygon{coordinates: [coords_a]}
    polygon_b = %Geo.Polygon{coordinates: [coords_b]}
    Topo.within?(polygon_a, polygon_b)
  end

  defp check_winding(ring, direction) do
    # create a list of coordinate pairs
    edges = ring
    |> Enum.with_index()
    |> Enum.reduce_while([], fn {point, i}, acc ->
      next_point = Enum.at(ring, i + 1)
      if is_nil(next_point) do
        {:halt, acc}
      else
        edge = {point, next_point}
        {:cont, [edge | acc]}
      end
    end)
    |> Enum.reverse

    # sum the edges' coordinates to get winding number
    winding_number = edges
      |> Enum.reduce(0, fn {{x1, y1}, {x2, y2}}, acc -> acc + ((x2 - x1) * (y2 - y1)) end)

    cond do
      # ring is clockwise, should be reversed
      winding_number < 0 and direction == :ccw ->
        Enum.reverse ring

      # ring is counter-clockwise, should be reversed
      winding_number > 0 and direction == :cw ->
        Enum.reverse ring

      # ring is fine
      true ->
        ring
    end
  end

end
