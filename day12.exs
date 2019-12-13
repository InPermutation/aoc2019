defmodule Day12 do
    def parse_moon(line) do
        line
            |> String.trim
            |> String.trim("<")
            |> String.trim(">")
            |> String.split(",")
            |> Enum.map(&String.trim/1)
            |> Enum.map(&parse_element/1)
    end

    defp parse_element(el) do
        [ axis, rest ] = String.split(el, "=")
        { String.to_atom(axis), String.to_integer(rest) }
    end
end


simstream = IO.stream(:stdio, :line)
    |> Stream.map(&Day12.parse_moon/1)
    |> Enum.to_list
    |> Day12.simulation_stream

simstream
    |> Stream.drop(1000 - 1)
    |> hd
    |> Day12.total_energy
    |> IO.inspect(label: "Part 1")
