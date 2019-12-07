defmodule Day4 do
    def six_digits(s), do: String.length(s) == 6

    def two_adjacent_digits_same(<<a, a, _rest::binary>>), do: true
    def two_adjacent_digits_same(<<_, rest::binary>>), do: two_adjacent_digits_same(rest)
    def two_adjacent_digits_same(""), do: false

    def digits_never_decrease(s, last \\ ?0)
    def digits_never_decrease("", _), do: true
    def digits_never_decrease(<<a, rest::binary>>, last) do
        if a < last do
            false
        else
            digits_never_decrease(rest, a)
        end
    end

    def exactly_two_adjacent_digits_same(s) do
        String.to_charlist(s)
            |> Enum.chunk_by(&identity/1)
            |> Enum.filter(fn chunk -> Enum.count(chunk) == 2 end)
            |> Enum.any?
    end

    defp identity(x), do: x
end


128392 .. 643281
    |> Stream.map(&Integer.to_string/1)
    |> Stream.filter(&Day4.six_digits/1)
    |> Stream.filter(&Day4.two_adjacent_digits_same/1)
    |> Stream.filter(&Day4.digits_never_decrease/1)
    |> Stream.filter(&Day4.exactly_two_adjacent_digits_same/1)
    |> Enum.count
    |> IO.puts

