defmodule Day8 do
    def count_zeroes(s), do: count(s, ?0)

    def count(charlist, char) do
        Enum.count(charlist, fn ch -> ch == char end)
    end

    def one_by_two(layer) do
        count(layer, ?1) * count(layer, ?2)
    end
end

layers = IO.read(:stdio, :all)
    |> String.trim
    |> String.to_charlist
    |> Enum.chunk_every(25 * 6)

layers
    |> Enum.min_by(&Day8.count_zeroes/1)
    |> Day8.one_by_two
    |> IO.inspect(label: "Part 1")
