defmodule Conrex.ConrexTest do
  use ExUnit.Case
  alias Conrex

  setup do
    x_coords = [0.07278200000000368,0.08629799999999932,0.09981399999999496,0.11333000000000482,0.12684600000000046,0.1403619999999961,0.15387800000000595,0.1673940000000016,0.18090999999999724,]
    y_coords = [0.17762400000000156,0.1945260000000033,0.21142799999999795,0.2283299999999997,0.24523200000000145,0.2621340000000032,0.27903599999999784,0.2959379999999996,]
    values = [
      [3600,4118.332867646932,980.9300654915393,922.4660102580684,3600,3600,3600,3600,],
      [3600,4985.558890423245,547.3580659423178,648.2753300284483,616.5646983422844,662.948967845521,812.3318746277183,3600,],
      [3600,1494.1679925149865,639.7927585651445,231.6572528834279,458.0027597563861,552.3797460173597,650.7838861395121,782.3158372549331,],
      [3600,1202.7058109290986,706.6746834495775,137.02530909529997,496.4312412969973,452.8162992478738,554.6357487220101,675.2464314966088,],
      [3600,1424.4911194724282,306.05560712456327,42.98402275115799,222.53975764000376,990.1288202954506,667.7344884342297,610.7149336954201,],
      [3600,903.1737233650425,325.86174354687154,427.069220819499,370.2923940903842,447.25758144529664,796.5249434461399,3600,],
      [2331.549382442632,653.1175726600683,370.65983665782693,500.83984790207177,554.4970950417792,631.3033586753324,890.3221251673195,3600,],
      [1328.4555574310448,529.1973859050354,467.3150563221315,627.0967730429414,636.2915081001195,778.6053046843165,3600,3600,],
      [760.012585798642,696.1575361079331,605.3173725494097,816.7112882619687,3600,3600,3600,3600,],
    ]

    {:ok, %{data: %{x_coords: x_coords, y_coords: y_coords, values: values}}}
  end

  test "conrec/4 outputs the correct number of segments", %{data: %{x_coords: x_coords, y_coords: y_coords, values: values}} do
    contours = Conrex.conrec(values, x_coords, y_coords, [600])

    # writes to "priv/static/contours.js" for visual verification
    write_js_test_file(x_coords, y_coords, values, contours)

    assert Enum.count(contours[600]) == 68
  end

  test "contour_polygons/5 generates polygon structs", %{data: %{x_coords: x_coords, y_coords: y_coords, values: values}} do
    polygons = Conrex.contour_polygons(values, x_coords, y_coords, [600], {0.12684600000000046, 0.2283299999999997})
    assert [{600, %Geo.Polygon{} = polygon}] = polygons
    assert Enum.count(List.first(polygon.coordinates)) == 69
  end

  defp write_js_test_file(xs, ys, values, contours) do
    {:ok, file} = File.open("priv/static/contour.js", [:write])

    IO.binwrite(file, "window.xs = [")
    Enum.map(xs, fn x -> IO.binwrite(file, "#{x},") end)
    IO.binwrite(file, "];\n")

    IO.binwrite(file, "window.ys = [")
    Enum.map(ys, fn y -> IO.binwrite(file, "#{y},") end)
    IO.binwrite(file, "];\n")

    IO.binwrite(file, "window.values = [\n")
    Enum.map(values, fn col ->
      IO.binwrite(file, "  [")
      Enum.map(col, fn value ->
        IO.binwrite(file, "#{value},")
      end)
      IO.binwrite(file, "],\n")
    end)
    IO.binwrite(file, "];\n")

    IO.binwrite(file, "window.drawContour = () => {\n")
    Enum.map(Map.values(contours), fn segments ->
      Enum.map(segments, fn {{x0, y0}, {x1, y1}} ->
        IO.binwrite(file, "  drawLine(#{x0}, #{y0}, #{x1}, #{y1});\n")
      end)
    end)
    IO.binwrite(file, "};")
    File.close(file)
  end
end
