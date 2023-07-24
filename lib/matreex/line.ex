defmodule Matreex.Line do
  alias ExTermbox.Constants

  {:ok, modules} = :application.get_key(:elixir, :modules)
  @words Enum.map(modules, &inspect(&1))

  @green Constants.color(:green)
  @bold_green Bitwise.bor(Constants.color(:green), Constants.attribute(:bold))

  @enforce_keys [:x, :length]

  defstruct content: [], word: [], x: 0, y: 0, current_length: 0, length: 0, done: false, color: @green

  def new(x, max_length) do
    length = :rand.uniform(max_length) + 3
    %Matreex.Line{content: [], word: [], x: x, y: -1, current_length: 0, length: length}
  end

  def move(line, max_y, _words) when line.y == max_y do
    content = List.delete_at(line.content, -1)
    %{line | content: content, done: true}
  end

  def move(line, _max_y, words) when line.current_length == line.length do
    line = add_char(line, words)
    content = List.delete_at(line.content, -1)
    %{line | content: content, y: line.y + 1}
  end

  def move(line, _max_y, words) do
    line = add_char(line, words)
    %{line | current_length: line.current_length + 1, y: line.y + 1}
  end

  def done?(line) do
    (line.current_length == line.length) and (line.y - line.length > 3)
  end

  def add_char(line, _words = false) do
    content = [random_char() | line.content]
    %{line | content: content}
  end

  def add_char(line, _words = true) do
    color = if line.word == [] do
      # :rand.uniform(8)
      if line.color == @green, do: @bold_green, else: @green
    else
      line.color
    end

    word = if line.word == [] do
      @words |> Enum.take_random(1) |> hd |> Kernel.<>(" ") |> String.to_charlist
    else
      line.word
    end

    [ch | word] = word
    content = [{ch, color} | line.content]

    %{line | content: content, word: word, color: color}
  end

  def random_char, do: 32 + :rand.uniform(127-33)
end
