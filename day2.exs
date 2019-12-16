defmodule Day2 do
    def run(mem, noun, verb) do
        final_state = mem
            |> List.replace_at(1, noun)
            |> List.replace_at(2, verb)
            |> Intcode.init
            |> Intcode.run

        hd final_state.mem
    end

end

mem = IO.read(:stdio, :all)
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)

IO.inspect(Day2.run(mem, 12, 02), label: "Part 1")

target = 19690720
pairs = for noun <- 0..99, verb <- 0..99, do: {noun, verb}

{noun, verb} = Enum.find(pairs, fn {noun, verb} ->
        Day2.run(mem, noun, verb) == target
    end)

IO.inspect(noun * 100 + verb, label: "Part 2")
