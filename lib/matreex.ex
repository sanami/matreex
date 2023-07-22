defmodule Matreex do
  alias ExTermbox.Bindings, as: Termbox
  alias ExTermbox.{Cell, EventManager, Event, Position}

  alias Matreex.Board

  @sleep 40

  def loop(_board, _sleep, _quit = true), do: :ok

  def loop(board, sleep, _quit) do
    Termbox.clear()

    board = board |> Board.move |> Board.draw

    print 0, board.max_y, "(Press <q> to quit) #{length(board.lines)} #{sleep}"

    Termbox.present()

    {quit, sleep} = receive do
      {:event, %Event{ch: ?q}} -> {true, sleep}
      {:event, %Event{ch: ?-}} -> {false, sleep+10}
      {:event, %Event{ch: ?=}} -> if sleep >= 20, do: {false, sleep-10}, else: {false, sleep}
    after
      sleep -> {false, sleep}
    end

    loop(board, sleep, quit)
  end

  def print(x, y, str) when is_binary(str) do
    str
    |> String.to_charlist
    |> Stream.with_index
    |> Enum.each(fn {ch, xx} ->
      Termbox.put_cell(%Cell{position: %Position{x: x+xx, y: y}, ch: ch})
    end)
  end

  def run do
    :ok = Termbox.init()
    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())

    {:ok, width} = Termbox.width
    {:ok, height} = Termbox.height
    board = Board.new(width - 1, height - 1)
    
    loop(board, @sleep, false)

    :ok = Termbox.shutdown()
  end
end
