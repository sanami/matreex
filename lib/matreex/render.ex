defmodule Matreex.Render do
  alias ExTermbox.Bindings, as: Termbox
  alias ExTermbox.{Cell, Position, Constants}

  @colors %{green: Constants.color(:green), white: Constants.color(:white), bold_green: Bitwise.bor(Constants.color(:green), Constants.attribute(:bold))}

  def draw_char(x, y, ch, fg_color) do
    Termbox.put_cell(%Cell{position: %Position{x: x, y: y}, ch: ch, fg: @colors[fg_color]})
  end
end
