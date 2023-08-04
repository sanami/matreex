defmodule Matreex.Line do
  {:ok, modules} = :application.get_key(:elixir, :modules)
  @words Enum.map(modules, &inspect(&1))

  @enforce_keys [:x, :length]

  defstruct content: [], word: [], x: 0, y: 0, speed: 1.0, current_length: 0, length: 0, done: false, color: :green

  def new(x, max_length) do
    color = [:green, :bold_green] |> Enum.take_random(1) |> hd()
    length = :rand.uniform(max_length) + 3
    # speed = 1
    speed = 0.5 + :rand.uniform / 2

    %Matreex.Line{content: [], word: [], x: x, y: -1, speed: speed, current_length: 0, length: length, color: color}
  end

  def move(line, max_y, words) do
    old_y = line.y
    line = %{line | y: line.y + line.speed}

    if trunc(line.y) > trunc(old_y) do
      update(line, max_y, words)
    else
      line
    end
  end

  def update(line, max_y, _words) when trunc(line.y) > max_y do
    content = List.delete_at(line.content, -1)
    %{line | content: content, done: true, y: line.y - 1}
  end

  def update(line, _max_y, words) when line.current_length == line.length do
    line = add_char(line, words)
    content = List.delete_at(line.content, -1)
    %{line | content: content}
  end

  def update(line, _max_y, words) do
    line = add_char(line, words)
    %{line | current_length: line.current_length + 1}
  end

  def done?(line) do
    (line.current_length == line.length) and (line.y - line.length > 10)
  end

  def add_char(line, words) do
    color = if line.word == [] do
      if line.color == :green, do: :bold_green, else: :green
    else
      line.color
    end

    word = if line.word == [] do
      if words do
        @words |> Enum.take_random(1) |> hd |> Kernel.<>(" ") |> String.to_charlist
      else
        for _i <- 1..:rand.uniform(10), do: random_char()
      end
    else
      line.word
    end

    [ch | word] = word
    content = [{ch, color} | line.content]

    %{line | content: content, word: word, color: color}
  end

  def random_char, do: 32 + :rand.uniform(127-33)
end
