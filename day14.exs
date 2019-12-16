defmodule Day14 do
    def parse_line(line) do
        line = String.trim(line)
        [inputs, output] = String.split(line, " => ")
        chemicals = inputs
            |> String.split(", ")
            |> Enum.map(&parse_chem/1)
        {c, product} = parse_chem(output)

        {String.to_atom(product), {c, chemicals}}
    end

    defp parse_chem(chem) do
        [c, name] = String.split(chem)

        {String.to_integer(c), name}
    end
end

products = IO.stream(:stdio, :line)
    |> Stream.map(&Day14.parse_line/1)
    |> Map.new # TODO: check for duplicate keys?

IO.inspect(Day14.produce("ORE", "FUEL"), label: "Part 1")
