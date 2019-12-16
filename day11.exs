defmodule Day11 do
    def run_robot(state, hull \\ %{}, loc \\ {0, 0}, dir \\ ?U) do
        state = run_until_2_outputs_or_stopped(state)
        if state.halted do
            {hull, loc, dir}
        else
            [color, turn] = state.output
            hull = Map.put(hull, loc, color)
            {x, y} = loc

            {loc, dir} = case {turn, dir} do
                {0, ?U} -> {{x - 1, y}, ?L}
                {1, ?U} -> {{x + 1, y}, ?R}
                {0, ?L} -> {{x, y + 1}, ?D}
                {1, ?L} -> {{x, y - 1}, ?U}
                {0, ?R} -> {{x, y - 1}, ?U}
                {1, ?R} -> {{x, y + 1}, ?D}
                {0, ?D} -> {{x + 1, y}, ?R}
                {1, ?D} -> {{x - 1, y}, ?L}
            end
            run_robot(%{state | input: [get_color(hull, loc)], output: []}, hull, loc, dir)
        end
    end

    def run_until_2_outputs_or_stopped(state) do
        if state.halted or Enum.count(state.output) >= 2 do
            state
        else
            run_until_2_outputs_or_stopped(Intcode.step(state))
        end
    end

    def get_color(hull, loc) do
        v = hull[loc]
        if v == nil, do: 0, else: v
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

{hull, _loc, _dir} = Day11.run_robot(Intcode.init(rom, [0]))

Enum.count(hull) |> IO.inspect(label: "Part 1")

IO.puts("Part 2:")
Day11.run_robot(Intcode.init(rom, [1]), %{{0, 0} => 1})
    |> Day11.visualize
