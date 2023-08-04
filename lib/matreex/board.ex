defmodule Matreex.Board do
  alias Matreex.{Line, Render}

  @enforce_keys [:max_x, :max_y]
  defstruct lines: [], max_x: 0, max_y: 0

  def new(max_x, max_y) do
    %Matreex.Board{lines: [], max_x: max_x, max_y: max_y}
  end

  def move(board, add_count, words \\ true) do
    lines =
      board.lines
      |> Enum.map(&Line.move(&1, board.max_y, words))
      |> Enum.reject(& &1.content == [])

    used_x = Enum.reduce lines, MapSet.new, fn line, used_x ->
      if Line.done?(line) do
        used_x
      else
        MapSet.put(used_x, line.x)
      end
    end
    
    free_x = MapSet.difference MapSet.new(0..board.max_x), used_x
    new_x = Enum.take_random(free_x, :rand.uniform(add_count))

    new_lines = Enum.map new_x, &Line.new(&1, trunc(board.max_y * 0.75))

    %{board | lines: lines ++ new_lines}
  end

  def draw(board, bold \\ false) do
    Enum.each board.lines, fn line ->
      line.content
      |> Stream.with_index
      |> Enum.each(fn
        {{ch, color}, i} when bold ->
          Render.draw_char(trunc(line.x), trunc(line.y - i), ch, color)

        {ch, i} ->
          color = if i == 0 && !line.done do
            :white
          else
            :green
          end

          ch = if is_tuple(ch), do: elem(ch, 0), else: ch

          Render.draw_char(trunc(line.x), trunc(line.y - i), ch, color)
      end)
    end

    board
  end
end
