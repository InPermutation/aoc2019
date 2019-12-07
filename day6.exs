defmodule Day6 do

    def update_map(line, map) do
        [body, satellite] = String.trim(line) |> String.split(")")
        Map.put(map, satellite, body)
    end

    def count_orbits(map) do
        Map.keys(map)
            |> Enum.map(&(hops_to_com(&1, map)))
            |> Enum.map(&Enum.count/1)
            |> Enum.sum
    end

    def hops_to_com("COM", _), do: []
    def hops_to_com(satellite, map) do
        next = Map.get(map, satellite)
        [satellite | hops_to_com(next, map)]
    end

end

map = IO.stream(:stdio, :line)
    |> Enum.reduce(%{}, &Day6.update_map/2)

Day6.count_orbits(map)
    |> IO.inspect

