defmodule Day2 do
    def run(mem, pc \\ 0) do
        op = Enum.fetch!(mem, pc)
        if op == 99 do
            mem
        else
            f = case op do
                1 -> &+/2
                2 -> &*/2
            end

            [pa, pb, out] = Enum.slice(mem, pc + 1, 3)
            [a, b] = [Enum.fetch!(mem, pa), Enum.fetch!(mem, pb)]
            res = f.(a, b)

            run(List.replace_at(mem, out, res), pc + 4)
        end
    end
end

mem = IO.read(:stdio, :all)
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)

target = 19690720
pairs = for noun <- 0..99, verb <- 0..99, do: {noun, verb}

{noun, verb} = Enum.find(pairs, fn {noun, verb} ->
        prog = mem |> List.replace_at(1, noun) |> List.replace_at(2, verb)
        res = Day2.run(prog)
        output = hd res

        target == output
    end)

IO.puts noun * 100 + verb
