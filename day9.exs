defmodule Day9 do
    def step(state) do
        word = fetch(state.mem, state.pc)
        decoded = decode(word)
        op = hd decoded
        modes = tl decoded

        {f, verbs} = case op do
            1 -> {&+/2, [:read, :read, :write]}
            2 -> {&*/2, [:read, :read, :write]}
            3 -> {&identity/1, [:input, :write]}
            4 -> {nil, [:read, :output]}
            5 -> {&nonzero/1, [:read, :cond]}
            6 -> {&zero/1, [:read, :cond]}
            7 -> {&lt/2, [:read, :read, :write]}
            8 -> {&eq/2, [:read, :read, :write]}
            99 -> {nil, [:halt]}
        end

        execute(f, verbs, modes, [], advance(state))
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

    def identity(x), do: x

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

    def execute(f, [], _, args, state) do
        :ok = apply(f, args)
        state
    end

    def execute(f, [:write], [0 | _], args, state) do
        res = apply(f, args)
        loc = fetch(state.mem, state.pc)
        advance(%{ state |
            mem: store(state.mem, loc, res)
        })
    end

    def execute(f, [:read|verbs], [mode|modes], args, state) do
        val = fetch(state.mem, state.pc, mode)
        execute(f, verbs, modes, args ++ [val], advance(state))
    end

    def execute(comparator, [:cond], [mode|_], [condition], state) do
        if comparator.(condition) do
            %{ state | pc: fetch(state.mem, state.pc, mode) }
        else
            advance(state)
        end
    end

    def execute(f, [:input|verbs], modes, args, state) do
        [val | remaining] = state.input
        execute(f, verbs, modes, args ++ [val], %{state | input: remaining})
    end

    def execute(nil, [:output], _, [arg], state) do
        %{state | output: state.output ++ [arg]}
    end

    def execute(nil, [:halt], _, [], state) do
        %{state | halted: true}
    end

    def advance(state) do
        %{ state | pc: state.pc + 1 }
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
end

rom = IO.gets("")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
