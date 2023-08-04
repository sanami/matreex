defmodule Matreex.LineTest do
  use AppCase, async: true

  alias Matreex.Line

  test "new" do
    res = Line.new(11, 33)
    pp res
    %{content: [], x: 11, y: y, current_length: 0, length: length} = res
    assert length > 0
    assert y in [0, -1]
  end

  test "move" do
    line1 = Line.new(0, 9)
    Enum.reduce 1..20, line1, fn _, line1 ->
      line1 = Line.move(line1, 10, true)
      pp line1
      line1
    end
  end

  test "add_char" do
    line1 = Line.new(0, 9)
    line1 = Line.add_char(line1, true)
    pp line1
    assert length(line1.word) > 0
    assert length(line1.content) > 0
  end

  test "random_char" do
    res = Line.random_char()
    assert res > 32
    assert res < 127
  end
end
