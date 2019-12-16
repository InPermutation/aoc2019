defmodule Day13 do
    def xrange(), do: 40
    def yrange(), do: 24

    def play(state, screen \\ init_screen(), score \\ 0) do
        cond do
            state.halted -> %{ score: score }
            Enum.count(state.output) == 3 ->
                modify_then_play(state, screen, score)
            true ->
                play(Intcode.step(state), screen, score)
        end
    end

    def modify_then_play(state, screen, score) do
        [x, y, v] = state.output
        if x == -1 && y == 0 do
            newstate = %{ state | output: [] }
            play(newstate, screen, v)
        else
            if find_ball(screen) && find_paddle(screen) && false do
                display!(screen)
                IO.inspect([bx: find_ball(screen), px: find_paddle(screen), d: follow_ball(screen)])
            end
            newscreen = update_screen(state.output, screen)
            newstate = %{ state | input: [ follow_ball(newscreen) ], output: []}
            play(newstate, newscreen, score)
        end
    end

    def display!(screen) do
        Enum.each(screen, fn row ->
            Enum.map(row, fn v ->
                case v do
                    0 -> ' '
                    1 -> '+'
                    2 -> '#'
                    3 -> '-'
                    4 -> '*'
                end
            end)
            |> IO.puts
        end)
    end

    def follow_ball(screen) do
        bx = find_ball(screen)
        px = find_paddle(screen)

        cond do
            bx > px -> +1
            bx < px -> -1
            true -> 0
        end
    end

    def find_ball(screen), do: find(screen, 4)
    def find_paddle(screen), do: find(screen, 3)

    def find([], _tid), do: nil
    def find([row | rest], tid) do
        ix = Enum.find_index(row, fn v -> v == tid end)
        if ix == nil do
            find(rest, tid)
        else
            ix
        end
    end

    def init_screen() do
        row = List.duplicate(0, xrange())
        List.duplicate(row, yrange())
    end

    def update_screen([x, y, tid], screen) do
        if y >= 0 && y < yrange() && x >= 0 && x <= xrange() do
            row = Enum.fetch!(screen, y)
                |> List.replace_at(x, tid)
                List.replace_at(screen, y, row)
        else
            raise "validation failed"
        end
    end
end

rom = IO.gets("")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)

state = Intcode.run(Intcode.init(rom, []))

state.output
    |> Enum.chunk_every(3)
    |> Enum.filter(fn [_x, _y, tile_id] -> tile_id == 2 end)
    |> Enum.count
    |> IO.inspect(label: "Part 1")

quarters = Intcode.init(List.replace_at(rom, 0, 2), [])

Day13.play(quarters)
    |> IO.inspect(label: "Part 2")
