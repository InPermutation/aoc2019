defmodule Day1 do
    def fuel(mass) do
        div(mass, 3) - 2
    end
end

IO.puts IO.stream(:stdio, :line) |>
    Stream.map(&String.trim(&1)) |>
    Stream.map(&String.to_integer(&1)) |>
    Stream.map(&Day1.fuel(&1)) |>
    Enum.sum
