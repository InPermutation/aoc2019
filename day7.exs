defmodule Day7 do
    def run_with(mem, input) do
        state = run(%{
            pc: 0,
            mem: mem,
            input: input,
            output: [],
            halted: false
        })

        [res] = state.output
        res
    end

    def run(state) do
        if state.halted do
            state
        else
            run(step(state))
        end
    end

    def initialize_feedback_loop(sequence, rom) do
        amp_a = run_until_halted_or_output(%{
                pc: 0,
                mem: rom,
                input: [hd(sequence), 0],
                output: [],
                halted: false
            })
        other_amps =
            Enum.scan(tl(sequence), amp_a, fn phase, prev ->
                run_until_halted_or_output(%{
                    pc: 0,
                    mem: rom,
                    input: [phase, hd(prev.output)],
                    output: [],
                    halted: false
                }) end)
        [amp_a | other_amps]
    end

    def feedback_loop([a,b,c,d,e]) do
        [input] = e.output
        next_a = run_until_halted_or_output(%{ a |
                input: [input],
                output: []
        })
        if next_a.halted do
            input
        else
            other_amps = Enum.scan([b, c, d, e], next_a, fn amp, prev ->
                [prev_output] = prev.output
                run_until_halted_or_output(%{ amp |
                    input: [prev_output],
                    output: []
                }) end)

            feedback_loop([next_a | other_amps])
        end
    end

    def run_until_halted_or_output(state) do
        if state.halted or state.output != [] do
            state
        else
            run_until_halted_or_output(step(state))
        end
    end

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

outputs = for sequence <- Day7.permutations(Enum.to_list(0..4)) do
    Enum.reduce(sequence, 0, &(Day7.run_with(rom, [&1, &2])))
end

IO.inspect(Enum.max(outputs), label: "Part 1")


feedback = for sequence <- Day7.permutations(Enum.to_list(5..9)) do
    amps = Day7.initialize_feedback_loop(sequence, rom)
    Day7.feedback_loop(amps)
end

IO.inspect(Enum.max(feedback), label: "Part 2")
