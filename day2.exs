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
    |> List.replace_at(1, 12)
    |> List.replace_at(2, 2)

IO.puts hd Day2.run(mem)
