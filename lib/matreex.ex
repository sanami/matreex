defmodule Matreex do
  alias ExTermbox.Bindings, as: Termbox
  alias ExTermbox.{Cell, EventManager, Event, Position, Constants}

  alias Matreex.Line

  @max_y 36
  @max_x 131

  def move(lines) do
    lines =
      lines
      |> Enum.map(&Line.move(&1, @max_y))
      |> Enum.reject(& &1.content == [])

    used_x = Enum.map(lines, & &1.x) |> MapSet.new
    free_x = MapSet.difference MapSet.new(0..@max_x), used_x
    new_x = Enum.take_random(free_x, 2)

    new_lines = Enum.map new_x, &Line.new(&1, @max_y)

    lines ++ new_lines
  end

  def draw(lines) do
    Enum.each lines, fn line ->
      line.content
      |> Stream.with_index
      |> Enum.each(fn {ch, i} ->
        color = if i == 0, do: Constants.color(:white), else: Constants.color(:green)
        Termbox.put_cell(%Cell{position: %Position{x: line.x, y: line.y - i}, ch: ch, fg: color})
      end)
    end

    for {ch, x} <- Enum.with_index(String.to_charlist "(Press <q> to quit) #{length(lines)}") do
      :ok = Termbox.put_cell(%Cell{position: %Position{x: x, y: @max_y}, ch: ch})
    end
  end

  def loop(_lines, _quit = true), do: :ok
  def loop(_lines = [], _quit), do: :ok

  def loop(lines, _quit) do
    Termbox.clear()

    lines = move(lines)
    draw(lines)

    Termbox.present()

    quit = receive do
      {:event, %Event{ch: ?q}} -> true
      after
        40 -> false
    end

    loop(lines, quit)
  end

  def run do
    :ok = Termbox.init()

    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())

    lines = for x <- 0..5, do: Line.new(:rand.uniform(@max_x), @max_y)

    loop(lines, false)

    :ok = Termbox.shutdown()
  end

  def info do
    :ok = Termbox.init()
    {:ok, h} = Termbox.height
    {:ok, w} = Termbox.width

    Termbox.put_cell(%Cell{position: %Position{x: 0, y: 0}, ch: ?0})
    Termbox.put_cell(%Cell{position: %Position{x: w-1, y: h-1}, ch: ?1})
    Termbox.present()

    IO.gets ""
    :ok = Termbox.shutdown()

    IO.inspect [h, w]
    IO.inspect "---"
  end
end
