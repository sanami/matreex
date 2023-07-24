defmodule Matreex.Line do
  {:ok, modules} = :application.get_key(:elixir, :modules)
  @words Enum.map(modules, &inspect(&1))

  @enforce_keys [:x, :length]

  defstruct content: [], word: [], x: 0, y: 0, current_length: 0, length: 0, done: false

  def new(x, max_length) do
    length = :rand.uniform(max_length) + 3
    %Matreex.Line{content: [], word: [], x: x, y: -1, current_length: 0, length: length}
  end

  def move(line, max_y) when line.y == max_y do
    content = List.delete_at(line.content, -1)
    %{line | content: content, done: true}
  end

  def move(line, _max_y) when line.current_length == line.length do
    line = add_char(line)
    content = List.delete_at(line.content, -1)
    %{line | content: content, y: line.y + 1}
  end

  def move(line, _max_y) do
    line = add_char(line)
    %{line | current_length: line.current_length + 1, y: line.y + 1}
  end

  def done?(line) do
    (line.current_length == line.length) and (line.y - line.length > 3)
  end

#  def add_char(line) do
#    ch = random_char()
#    content = [ch | line.content]
#
#    %{line | content: content}
#  end

  def add_char(line) do
    word = if line.word == [] do
      @words |> Enum.take_random(1) |> hd |> Kernel.<>(" ") |> String.to_charlist
    else
      line.word
    end

    [ch | word] = word
    content = [ch | line.content]

    %{line | content: content, word: word}
  end

  def random_char, do: 32 + :rand.uniform(127-33)
end
