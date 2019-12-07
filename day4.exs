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
end


128392 .. 643281
    |> Stream.map(&Integer.to_string/1)
    |> Stream.filter(&Day4.six_digits/1)
    |> Stream.filter(&Day4.two_adjacent_digits_same/1)
    |> Stream.filter(&Day4.digits_never_decrease/1)
    |> Enum.count
    |> IO.puts

