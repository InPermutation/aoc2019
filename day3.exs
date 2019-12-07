defmodule Day3 do
    def pathToSegment(path, pt \\ {0, 0}, res \\ []) do
        if path == [] do
            res
        else
            [head | tail] = path
            pt1 = segment(pt, head)

            pathToSegment(tail, pt1, [{pt, pt1} | res])
        end
    end

    defp segment(pt, motion) do
        {dir, val} = String.split_at(motion, 1)
        d = String.to_integer(val)
        {x, y} = pt

        case dir do
            "U" -> {x, y + d}
            "D" -> {x, y - d}
            "L" -> {x - d, y}
            "R" -> {x + d, y}
        end
    end

    def intersections(wires) do
        left = hd(wires)
        right = hd(tl(wires))

        for a <- left,
            b <- right,
            x = intersection(a, b),
            do: x
    end

    defp intersection(a, b) do
        cond do
            is_horiz(a) && is_vert(b) -> hz_intersect(a, b)
            is_vert(a) && is_horiz(b) -> hz_intersect(b, a)
            true -> nil
        end
    end

    def is_horiz(pt) do
        {{x1, y1}, {x2, y2}} = pt
        x1 != x2 && y1 == y2
    end

    def is_vert(pt) do
        {{x1, y1}, {x2, y2}} = pt
        x1 == x2 && y1 != y2
    end

    defp hz_intersect(h, v) do
        {{x1, y}, {x2, y}} = h
        {{x, y1}, {x, y2}} = v
        i = {x, y}
        if Enum.member?(x1..x2, x) &&
            Enum.member?(y1..y2, y) do
            i
        else
            nil
        end
    end

    def distance(pt) do
        {x, y} = pt
        abs(x) + abs(y)
    end
end

IO.stream(:stdio, :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(String.split(&1, ",")))
    |> Stream.map(&Day3.pathToSegment/1)
    |> Enum.to_list
    |> Day3.intersections
    |> Enum.min_by(&Day3.distance/1)
    |> IO.inspect()
    |> Day3.distance()
    |> IO.puts()
