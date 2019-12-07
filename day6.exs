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

    def minimum_transfers([x|you_path], [x|san_path]) do
        minimum_transfers(you_path, san_path)
    end

    def minimum_transfers(you_path, san_path) do
        {you_path, san_path}
    end

end

map = IO.stream(:stdio, :line)
    |> Enum.reduce(%{}, &Day6.update_map/2)

Day6.count_orbits(map)
    |> IO.inspect

you_path = Enum.reverse(tl(Day6.hops_to_com("YOU", map)))
san_path = Enum.reverse(tl(Day6.hops_to_com("SAN", map)))
{to_gco, from_gco} = Day6.minimum_transfers(you_path, san_path)

IO.inspect(Enum.count(to_gco) + Enum.count(from_gco))
