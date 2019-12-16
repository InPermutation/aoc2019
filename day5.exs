defmodule Day5 do
    def diagnostic_code(mem, input) do
        state = Intcode.init(mem, input)
            |> Intcode.run
        state.output
    end

    def strip_zeroes([0 | r]), do: strip_zeroes(r)
    def strip_zeroes([v]), do: v
end

rom = IO.gets("")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)


diagnostic_code = Day5.strip_zeroes(Day5.diagnostic_code(rom, [1]))
IO.inspect(diagnostic_code, label: "Part 1")

[ diagnostic_code ] = Day5.diagnostic_code(rom, [5])
IO.inspect(diagnostic_code, label: "Part 2")
