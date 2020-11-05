# Conrex

![Example output visualization](https://github.com/NAISorg/conrex/raw/master/priv/static/screenshot.png)

This is an implementation of [Paul Bourke's CONREC algorithm in Elixir](http://paulbourke.net/papers/conrec/).

## Installation

Conrex can be installed by adding `conrex` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:conrex, "~> 1.0.0"}
  ]
end
```

## Usage

The main algorithm outlined by Bourke can be invoked with `Conrex.conrec`:

```
Conrex.conrec(values, x_coords, y_coords, contour_levels)
```

where `values` is a 2D list of samples (heights, travel times, etc), `x_coords`
and `y_coords` are lists of X and Y coordinates for the sample grid, and
`contour_levels` is a list of values at which a contour should be calculated.
`Conrex.conrec` outputs a list of line segments to match the classic algorithm.

If the X and Y values are GPS coordinates, you can use `Conrex.contour_polygons`
to generate `%Geo.Polygon{}`s for each contour level:

```
Conrex.contour_polygons(values, x_coords, y_coords, contour_levels, reference_point)
```

The additional parameter, `reference_point`, is a point known to be within the
contour polygobn, but outside any polygon holes. When converting the line
segments to GeoJSON `%Geo.Polygon{}`s, Conrex will discard exterior polygon
rings, and correct the coordinate winding for the main ring and the polygon
holes to conform to the GeoJSON spec.
