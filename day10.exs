defmodule Day10 do
    def to_pointslist(lines) do
        lines
            |> Stream.with_index
            |> Enum.flat_map(fn {line, y} ->
                String.to_charlist(line)
                    |> Enum.with_index
                    |> Enum.filter(fn {cell, _} -> cell == ?# end)
                    |> Enum.map(fn {_, x} -> {x, y} end)
            end)
    end

    def visible_from(origin, asteroids) do
        {max_x, max_y} = Enum.max_by(asteroids, fn {x, y} -> max(x, y) end)
        biggest_coord = max(max_x, max_y)
        others = asteroids -- [origin]
        blocked = blocked_spaces(others, origin, biggest_coord)
        visible = others -- blocked

        Enum.count(visible)
    end

    def blocked_spaces(others, origin, biggest_coord) do
        Enum.flat_map(others, fn other ->
            stride_of(other, origin, biggest_coord)
        end)
    end

    def stride_of(other, origin, biggest_coord) do
        diff = sub(other, origin)
        smaller = simplify(diff)


        Stream.unfold(other, fn p -> { add(smaller, p), add(smaller, p) } end)
            |> Stream.take_while(fn {x, y} ->
                x >= 0 && y >= 0 && x <= biggest_coord && y <= biggest_coord
            end)
            |> Enum.to_list
    end

    def add({x1, y1}, {x0, y0}), do: {x1 + x0, y1 + y0}
    def sub({x1, y1}, {x0, y0}), do: {x1 - x0, y1 - y0}

    def simplify({x, y}) do
        divisor = gcd(x, y)
        {div(x, divisor), div(y, divisor)}
    end

    def gcd(a, b) when a < 0, do: gcd(-a, b)
    def gcd(a, b) when b < 0, do: gcd(a, -b)
    def gcd(a, b) when a < b, do: gcd(b, a)
    def gcd(a, 0), do: a
    def gcd(a, b), do: gcd(b, rem(a, b))
end

asteroids = IO.stream(:stdio, :line)
    |> Stream.map(&String.trim/1)
    |> Day10.to_pointslist

asteroids
    |> Enum.map(fn asteroid -> Day10.visible_from(asteroid, asteroids) end)
    |> Enum.max
    |> IO.inspect(label: "Part 1")
