defmodule Day7 do
    def run_with(_mem, _phase, _input_signal) do
        raise "not impl"
    end

    def run(mem, input, output, pc \\ 0) do
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
                #3 -> {&input/0, [:write]}
                #4 -> {&output/1, [:read]}
                5 -> {&nonzero/1, [:read, :cond]}
                6 -> {&zero/1, [:read, :cond]}
                7 -> {&lt/2, [:read, :read, :write]}
                8 -> {&eq/2, [:read, :read, :write]}
            end

            {new_mem, new_pc} = execute(f, verbs, modes, [], mem, pc + 1)
            run(new_mem, input, output, new_pc)
        end
    end

    def fetch(mem, ix, mode \\ 1) do
        val = Enum.fetch!(mem, ix)
        if mode == 1 do
            val
        else
            Enum.fetch!(mem, val)
        end
    end

    def store(mem, ix, val) do
        List.replace_at(mem, ix, val)
    end

    def nonzero(x) do
        x != 0
    end

    def zero(x) do
        x == 0
    end

    def lt(a, b) do
        if a < b do
            1
        else
            0
        end
    end

    def eq(a, b) do
        if a == b do
            1
        else
            0
        end
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
        val = fetch(mem, pc, mode)
        execute(f, verbs, modes, args ++ [val], mem, pc + 1)
    end

    def execute(comparator, [:cond], [mode | _], [condition], mem, pc) do
        if comparator.(condition) do
            { mem, fetch(mem, pc, mode) }

        else
            { mem, pc + 1 }
        end


    end

    def decode(abcde) do
        de = rem(abcde, 100)
        abc = div(abcde, 100)
        c = rem(abc, 10)
        ab = div(abc, 10)
        b = rem(ab, 10)
        a = div(ab, 10)

        [de, c, b, a]
    end

    def permutations([]), do: [[]]

    def permutations(values) do
        # no duplicates because of the `--`
        for element <- values, remainder <- permutations(values -- [element]) do
            [element | remainder]
        end
    end
end

rom = IO.gets("")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)

for sequence <- Day7.permutations(Enum.to_list(0..4)) do
    thruster = Enum.reduce(sequence, 0, &(Day7.run_with(rom, &1, &2)))
    thruster
end
|> Enum.max


