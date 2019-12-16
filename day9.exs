rom = IO.gets("")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)

state = Intcode.init(rom, [1])
[keycode] = Intcode.run(state).output
IO.inspect(keycode, label: "Part 1")

state = Intcode.init(rom, [2])
[coordinates] = Intcode.run(state).output
IO.inspect(coordinates, label: "Part 2")
