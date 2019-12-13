defmodule Day13 do
    def run(state) do
        if state.halted do
            state
        else
            run(step(state))
        end
    end

    def init(mem, input) do
        %{
            pc: 0,
            mem: mem,
            halted: false,
            input: input,
            output: [],
            relative_base: 0
        }
    end

    def step(state) do
        word = fetch(state, 1)
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
            9 -> {nil, [:read, :rel]}
            99 -> {nil, [:halt]}
        end

        execute(f, verbs, modes, [], advance(state))
    end

    def fetch(state, mode \\ 1) do
        mem = state.mem
        ix = state.pc
        val = direct_fetch_or_zero(mem, ix)
        res = case mode do
            0 -> direct_fetch_or_zero(mem, val)
            1 -> val
            2 -> direct_fetch_or_zero(mem, val + state.relative_base)
        end
        res
    end

    def direct_fetch_or_zero(mem, val) do
        if val < Enum.count(mem) do
            Enum.fetch!(mem, val)
        else
            0
        end
    end

    def store(mem, ix, val) do
        size = Enum.count(mem)
        if ix < size do
            List.replace_at(mem, ix, val)
        else
            store(mem ++ List.duplicate(0, ix - size + 1), ix, val)
        end
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

    def execute(f, [:write], [mode | _], args, state) do
        res = apply(f, args)
        offset = case mode do
            0 -> 0
            2 -> state.relative_base
        end
        loc = fetch(state) + offset
        advance(%{ state |
            mem: store(state.mem, loc, res)
        })
    end

    def execute(f, [:read|verbs], [mode|modes], args, state) do
        val = fetch(state, mode)
        execute(f, verbs, modes, args ++ [val], advance(state))
    end

    def execute(comparator, [:cond], [mode|_], [condition], state) do
        if comparator.(condition) do
            %{ state | pc: fetch(state, mode) }
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

    def execute(nil, [:rel], _, args, state) do
        [val] = args
        %{ state | relative_base: state.relative_base + val }
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

    def visualize({hull, _loc, _dir}) do
        keys = Map.keys(hull)
        {x_min, x_max} = Enum.min_max(Enum.map(keys, fn {x, _y} -> x end))
        {y_min, y_max} = Enum.min_max(Enum.map(keys, fn {_x, y} -> y end))

        for y <- y_min..y_max do
            for x <- x_min..x_max do
                pix = case hull[{x, y}] do
                    nil -> ' '
                    0 -> ' '
                    1 -> '#'
                end
                IO.write(pix)
            end
            IO.puts("")
        end

    end
end

rom = IO.gets("")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)

state = Day13.run(Day13.init(rom, []))

state.output
    |> Enum.chunk_every(3)
    |> Enum.filter(fn [_x, _y, tile_id] -> tile_id == 2 end)
    |> Enum.count
    |> IO.inspect(label: "Part 1")
