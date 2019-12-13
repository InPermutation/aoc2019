defmodule Day12 do
    def axes(), do: [:x, :y, :z]

    def parse_moon(line) do
        line
            |> String.trim
            |> String.trim("<")
            |> String.trim(">")
            |> String.split(",")
            |> Enum.map(&String.trim/1)
            |> Enum.map(&parse_element/1)
            |> initialize_velocity
    end

    defp parse_element(el) do
        [ axis, rest ] = String.split(el, "=")
        { String.to_atom(axis), String.to_integer(rest) }
    end

    defp initialize_velocity(pos) do
        %{ pos: pos, vel: Enum.map(axes(), fn a -> {a, 0} end) }
    end

    def simulation_stream(moons) do
        Stream.iterate(moons, &step/1)
    end

    def step(moons), do: moons |> gravity |> velocity

    def gravity([]), do: []
    def gravity([moon | remaining]) do
        remaining = Enum.map(remaining, fn m -> update_velocity(moon, m) end)
        moon = Enum.reduce(remaining, moon, fn m, acc -> update_velocity(m, acc) end)
        [ moon | gravity(remaining) ]
    end

    def update_velocity(partner, self) do
        %{ pos: self.pos,
            vel: Enum.map(axes(), fn axis ->
                update_axis(axis, partner.pos, self) end)
        }
    end

    def update_axis(axis, partner_pos, self) do
        p_val = Keyword.fetch!(partner_pos, axis)
        s_val = Keyword.fetch!(self.pos, axis)
        s_vel = Keyword.fetch!(self.vel, axis)
        new_vel = s_vel + cond do
            p_val > s_val -> +1
            p_val < s_val -> -1
            p_val == s_val -> 0
        end

        { axis, new_vel }
    end

    def velocity(moons), do: Enum.map(moons, &update_pos/1)

    def update_pos(moon) do
        %{ moon |
            :pos => add(moon.pos, moon.vel) }
    end

    def add(pos, vel) do
        Enum.map(axes(), fn axis ->
            {axis, Keyword.fetch!(pos, axis) + Keyword.fetch!(vel, axis) }
        end)
    end

    def total_energy(moons) do
        moons
            |> Enum.map(&energy/1)
            |> Enum.sum
    end

    def energy(moon) do
        potential = Enum.map(moon.pos, fn {_axis, coord} -> abs(coord) end) |> Enum.sum
        kinetic = Enum.map(moon.vel, fn {_axis, coord} -> abs(coord) end) |> Enum.sum

        potential * kinetic
    end
end


simstream = IO.stream(:stdio, :line)
    |> Stream.map(&Day12.parse_moon/1)
    |> Enum.to_list
    |> Day12.simulation_stream

simstream
    |> Enum.at(1000)
    |> Day12.total_energy
    |> IO.inspect(label: "Part 1")
