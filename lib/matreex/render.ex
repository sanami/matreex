defmodule Matreex.Render do
  alias ExTermbox.Bindings, as: Termbox
  alias ExTermbox.{Cell, Position, Constants}

  @colors %{green: Constants.color(:green),
    white: Constants.color(:white),
    bold_green: Bitwise.bor(Constants.color(:green), Constants.attribute(:bold)),
    bold_white: Bitwise.bor(Constants.color(:white), Constants.attribute(:bold)),
  }

  def draw_char(x, y, ch, fg_color) do
    Termbox.put_cell(%Cell{position: %Position{x: x, y: y}, ch: ch, fg: @colors[fg_color]})
  end

  def print(x, y, str, first_bold \\ false) when is_binary(str) do
    str # <> "#{String.length(str)}"
    |> String.to_charlist
    |> Stream.with_index
    |> Enum.each(fn {ch, i} ->
      color = if first_bold && i == 0, do: @colors[:bold_white], else: @colors[:white]
      Termbox.put_cell(%Cell{position: %Position{x: x+i, y: y}, ch: ch, fg: color})
    end)
  end
end
