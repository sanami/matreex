defmodule Matreex.BoardTest do
  use AppCase, async: true

  alias Matreex.Board

  test "new" do
    res = Board.new(1, 2)
    pp res
    assert %{lines: [], max_x: 1, max_y: 2} = res
  end
end
