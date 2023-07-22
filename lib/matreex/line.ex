defmodule Matreex.Line do
  @enforce_keys [:x, :length]

  defstruct content: [], x: 0, y: 0, current_length: 0, length: 0

  def new(x, max_length) do
    %Matreex.Line{content: [], x: x, y: 0, current_length: 0, length: :rand.uniform(max_length)+3}
  end

  def move(line, max_y) when line.y == max_y do
    content = List.delete_at(line.content, -1)
    %{line | content: content}
  end

  def move(line, _max_y) when line.current_length == line.length do
    content = [random_char() | line.content] |> List.delete_at(-1)
    %{line | content: content, y: line.y + 1}
  end

  def move(line, _max_y) do
    content = [random_char() | line.content]
    %{line | content: content, current_length: line.current_length + 1, y: line.y + 1}
  end

  def random_char, do: 32 + :rand.uniform(127-33)
end
