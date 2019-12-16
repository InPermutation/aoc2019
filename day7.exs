defmodule Day7 do
    def run_with(mem, input) do
        state = Intcode.init(mem, input)
        state = Intcode.run(state)

        [res] = state.output
        res
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
            run_until_halted_or_output(Intcode.step(state))
        end
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
