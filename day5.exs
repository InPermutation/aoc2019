defmodule Day5 do
    def run(mem, pc \\ 0) do
        word = fetch(mem, pc)
        decoded = decode(word)
        op = hd decoded
        modes = tl decoded

        if op == 99 do
            mem
        else
            {f, verbs} = case op do
                1 -> {&+/2, [:read, :read, :write]}
                2 -> {&*/2, [:read, :read, :write]}
                3 -> {&input/0, [:write]}
                4 -> {&IO.puts/1, [:read]}
            end

            {new_mem, new_pc} = execute(f, verbs, modes, [], mem, pc + 1)
            run(new_mem, new_pc)
        end
    end

    def fetch(mem, ix) do
        Enum.fetch!(mem, ix)
    end

    def store(mem, ix, val) do
        List.replace_at(mem, ix, val)
    end

    def execute(f, [], _, args, mem, pc) do
        :ok = apply(f, args)
        {
            mem,
            pc
        }
    end

    def execute(f, [:write], [0 | _], args, mem, pc) do
        res = apply(f, args)
        loc = fetch(mem, pc)
        {
            store(mem, loc, res),
            pc + 1
        }
    end

    def execute(f, [:read|verbs], [mode|modes], args, mem, pc) do
        loc = fetch(mem, pc)
        val = case mode do
            0 -> fetch(mem, loc)
            1 -> loc
        end
        execute(f, verbs, modes, args ++ [val], mem, pc + 1)
    end

    defp input(), do: String.to_integer(String.trim(IO.gets("")))

    def decode(abcde) do
        de = rem(abcde, 100)
        abc = div(abcde, 100)
        c = rem(abc, 10)
        ab = div(abc, 10)
        b = rem(ab, 10)
        a = div(ab, 10)

        [de, c, b, a]
    end
end

rom = IO.gets("")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)

Day5.run(rom)
