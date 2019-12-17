defmodule Day15 do
    def breadth_first_search(map, [s | frontier], terminate?) do
        [state: state, loc: loc] = s
        if rem(Enum.count(map), 1000) == 0 do
            IO.inspect([loc: loc, fsize: Enum.count(frontier), msize: Enum.count(map)])
            {{xmin, _}, {xmax, _}} = Enum.min_max_by(Map.keys(map), fn {x, _} -> x end)
            {{_, ymin}, {_, ymax}} = Enum.min_max_by(Map.keys(map), fn {_, y} -> y end)

            for y <- ymin..ymax do
                for x <- xmin..xmax do
                    t = Map.get(map, {x, y})
                    IO.write(case t do
                        nil -> '.'
                        :wall -> '#'
                        _ -> ' '
                    end)
                end
                IO.puts("")
            end
        end
        next_states = generate_next_states(state, loc, map, frontier)

        d = Map.fetch!(map, loc)
        map = update_map(d, map, next_states)

        frontier = frontier ++
            Enum.filter(next_states, fn state -> !wall?(state) end)
        if terminate?.(frontier) do
            {map, frontier}
        else
            breadth_first_search(map, frontier, terminate?)
        end
    end

    def distance_to([state: _state, loc: loc], map) do
        Map.fetch!(map, loc)
    end

    def oxy?([state: state, loc: _]), do: [2] == state.output

    def wall?([state: state, loc: _]), do: [0] == state.output

    def found_oxy?(frontier) do
        Enum.any?(frontier, &oxy?/1)
    end

    defp ewsn({x, y}), do: [
        {1, {x, y - 1}},
        {2, {x, y + 1}},
        {3, {x - 1, y}},
        {4, {x + 1, y}}
    ]

    defp generate_next_states(state, loc, map, frontier) do
        ewsn(loc)
            |> Enum.filter(fn {_ins, el} -> !Map.has_key?(map, el) end)
            |> Enum.filter(fn {_ins, el} -> !in_frontier(frontier, el) end)
            |> Enum.map(fn {ins, el} ->
                [state: run_until_output(%{ state | input: [ ins ], output: []}), loc: el]
            end)
    end

    defp in_frontier(frontier, el) do
        Enum.any?(frontier, fn [state: _state, loc: loc] -> el == loc end)
    end

    def run_until_output(state) do
        if state.output != [] do
            state
        else
            run_until_output(Intcode.step(state))
        end
    end

    defp update_map(_d, map, []), do: map
    defp update_map(d, map, [s |states]) do
        { k, v } = transform_state(s, d)
        update_map(d, Map.put(map, k, v), states)
    end

    defp transform_state(s, d) do
        [state: state, loc: loc] = s

        [ ov ] = state.output
        case ov do
            0 -> { loc, :wall }
            _ -> { loc, d + 1 }
        end
    end

end

rom = IO.gets("")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)

origin = {0, 0}
map = %{ origin => 0 }
frontier = [ [state: Intcode.init(rom), loc: origin] ]
{ map, frontier } = Day15.breadth_first_search(map, frontier, &Day15.found_oxy?/1)
[oxy] = frontier |> Enum.filter(&Day15.oxy?/1)
d = Day15.distance_to(oxy, map)

IO.inspect(d, label: "Part 1")

