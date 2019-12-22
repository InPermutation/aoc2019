defmodule Day14 do
    def parse_line(line) do
        line = String.trim(line)
        [inputs, output] = String.split(line, " => ")
        chemicals = inputs
            |> String.split(", ")
            |> Enum.map(&parse_chem/1)
        {c, product} = parse_chem(output)

        {product, {c, chemicals}}
    end

    defp parse_chem(chem) do
        [c, name] = String.split(chem)

        {String.to_integer(c), name}
    end

    def produce(products, target, extras \\ %{})
    def produce(_products, {0, _target}, extras), do: {0, extras}
    def produce(_products, {need, "ORE"}, extras), do: {need, extras}

    def produce(products, {need, target}, extras) do
        {need, extras}
        {need, extras} = greedy_consume(need, target, extras)

        {yield, recipe} = required_ingredients(products, need, target)

        extras = unuse(yield - need, target, extras)

        {ore, extras} = Enum.reduce(recipe, {0, extras},
            fn el, acc -> produce_one(products, el, acc) end)

        {ore, extras}
    end

    def produce_one(products, el, {o0, extras}) do
        {o1, extras} = produce(products, el, extras)
        {o0 + o1, extras}
    end

    def greedy_consume(need, target, extras) do
        case Map.get(extras, target) do
            nil -> {need, extras}
            ^need -> {0, Map.delete(extras, target)}
            have ->
                if have > need do
                    {0, Map.put(extras, target, have - need)}
                else
                    {need - have, Map.delete(extras, target)}
                end
        end
    end

    def unuse(0, _, extras), do: extras
    def unuse(leftovers, target, extras) do
        Map.update(extras, target, leftovers, &(&1 + leftovers))
    end

    def required_ingredients(_, 0, _), do: {0, %{}}
    def required_ingredients(products, need, target) do
        {yield, recipe} = Map.fetch!(products, target)
        if yield >= need do
            {yield, recipe}
        else
            factor = div(need + yield - 1, yield)
            {factor * yield, mul(factor, recipe)}
        end
    end

    def mul(n, recipe) do
        Enum.map(recipe, fn {amt, target} -> {amt * n, target} end)
    end
end

products = IO.stream(:stdio, :line)
    |> Stream.map(&Day14.parse_line/1)
    |> Map.new

{ore, _leftovers} = Day14.produce(products, {1, "FUEL"})

IO.inspect(ore, label: "Part 1")
