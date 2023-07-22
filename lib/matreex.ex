defmodule Matreex do
  alias ExTermbox.Bindings, as: Termbox
  alias ExTermbox.{Cell, EventManager, Event, Position}

  alias Matreex.Board

  @sleep 50

  def loop(_board, _sleep, _quit = true), do: :ok

  def loop(board, sleep, _quit) do
    Termbox.clear()

    board = board |> Board.move |> Board.draw

    for {ch, x} <- Enum.with_index(String.to_charlist "(Press <q> to quit) #{length(board.lines)} #{sleep}") do
      :ok = Termbox.put_cell(%Cell{position: %Position{x: x, y: board.max_y}, ch: ch})
    end

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
