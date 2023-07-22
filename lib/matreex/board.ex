defmodule Matreex.Board do
  alias ExTermbox.Bindings, as: Termbox
  alias ExTermbox.{Cell, Position, Constants}

  alias Matreex.Line

  @enforce_keys [:max_x, :max_y]
  defstruct lines: [], max_x: 0, max_y: 0

  def new(max_x, max_y) do
    %Matreex.Board{lines: [], max_x: max_x, max_y: max_y}
  end

  def move(board) do
    lines =
      board.lines
      |> Enum.map(&Line.move(&1, board.max_y))
      |> Enum.reject(& &1.content == [])

    used_x = Enum.reduce lines, MapSet.new, fn line, used_x ->
      if Line.done?(line) do
        used_x
      else
        MapSet.put(used_x, line.x)
      end
    end
    
    free_x = MapSet.difference MapSet.new(0..board.max_x), used_x
    new_x = Enum.take_random(free_x, 3)

    new_lines = Enum.map new_x, &Line.new(&1, board.max_y)

    %{board | lines: lines ++ new_lines}
  end

  def draw(board) do
    Enum.each board.lines, fn line ->
      line.content
      |> Stream.with_index
      |> Enum.each(fn {ch, i} ->
        color = if i == 0 && !line.done, do: Constants.color(:white), else: Constants.color(:green)
        
        Termbox.put_cell(%Cell{position: %Position{x: line.x, y: line.y - i}, ch: ch, fg: color})
      end)
    end

    board
  end
end
