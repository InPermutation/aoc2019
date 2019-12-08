defmodule Day8 do
    def count_zeroes(s), do: count(s, ?0)

    def count(charlist, char) do
        Enum.count(charlist, fn ch -> ch == char end)
    end

    def one_by_two(layer) do
        count(layer, ?1) * count(layer, ?2)
    end

    def composite(fore, aft) do
        Enum.zip(fore, aft)
            |> Enum.map(&composite_one/1)
    end

    def composite_one({?2, aft}), do: aft
    def composite_one({fore, _aft}), do: fore

    def puts(s) do
        Enum.map(s, fn ch -> if ch == ?1 do '*' else ' ' end end)
        |> IO.puts
    end
end

[columns, rows] = [25, 6]

layers = IO.read(:stdio, :all)
    |> String.trim
    |> String.to_charlist
    |> Enum.chunk_every(columns * rows)

layers
    |> Enum.min_by(&Day8.count_zeroes/1)
    |> Day8.one_by_two
    |> IO.inspect(label: "Part 1")

IO.puts("Part 2:")
layers
    |> Enum.reverse
    |> Enum.reduce(&Day8.composite/2)
    |> Enum.chunk_every(columns)
    |> Enum.each(&Day8.puts/1)
