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
iex> Conrex.conrec(values, x_coords, y_coords, contour_levels)
```

where `values` is a 2D list of samples (heights, travel times, etc), `x_coords`
and `y_coords` are lists of X and Y coordinates for the sample grid, and
`contour_levels` is a list of values at which a contour should be calculated.
`Conrex.conrec` outputs a list of line segments to match the classic algorithm.

If the X and Y values are GPS coordinates, you can use `Conrex.contour_polygons`
to generate GeoJSON polygons for each contour level:

```
iex> Conrex.contour_polygons(values, x_coords, y_coords, contour_levels, reference_point)
```

The additional parameter, `reference_point`, is a point known to be within the
contour polygon, but outside any polygon holes. When converting the line
segments to GeoJSON `%Geo.Polygon{}`s, Conrex will discard exterior polygon
rings, and correct the coordinate winding for the main ring and the polygon
holes to conform to the [GeoJSON spec](https://tools.ietf.org/html/rfc7946#section-3.1.6).

## Contributing

Pull requests are welcome. For major changes, please open an issue first to
discuss what you would like to change.

Some of the tests will write output and sample data to a `contour.js` file,
which can be used to visualize the test data and result. The visualization can
be seen by viewing `priv/static/index.html` in a web browser.

## License

[MIT](https://choosealicense.com/licenses/mit/)
