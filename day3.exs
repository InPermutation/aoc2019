defmodule Day3 do
    def pathToSegment(path, pt \\ {0, 0, 0}, res \\ []) do
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
        {x, y, d0} = pt

        case dir do
            "U" -> {x, y + d, d0 + d}
            "D" -> {x, y - d, d0 + d}
            "L" -> {x - d, y, d0 + d}
            "R" -> {x + d, y, d0 + d}
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
        {{x1, y1, _d1}, {x2, y2, _d2}} = pt
        x1 != x2 && y1 == y2
    end

    def is_vert(pt) do
        {{x1, y1, _d1}, {x2, y2, _d2}} = pt
        x1 == x2 && y1 != y2
    end

    defp hz_intersect(h, v) do
        {{x1, y, d1}, {x2, y, _d1}} = h
        {{x, y1, d2}, {x, y2, _d2}} = v

        pd1 = d1 + abs(x - x1)
        pd2 = d2 + abs(y - y1)

        i = {x, y, pd1 + pd2}
        if pd1 + pd2 == 0 do
            nil
        else
            if Enum.member?(x1..x2, x) &&
                Enum.member?(y1..y2, y) do
                i
            else
                nil
            end
        end
    end

    def steps({_, _, d}), do: d
end

IO.stream(:stdio, :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(String.split(&1, ",")))
    |> Stream.map(&Day3.pathToSegment/1)
    |> Enum.to_list
    |> Day3.intersections
    |> Enum.min_by(&Day3.steps/1)
    |> IO.inspect()
    |> Day3.steps()
    |> IO.puts()
