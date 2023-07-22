defmodule Matreex do
  alias ExTermbox.Bindings, as: Termbox
  alias ExTermbox.{Cell, EventManager, Event, Position}

  alias Matreex.Board

  @sleep 40

  def loop(_board, _quit = true), do: :ok

  def loop(board, _quit) do
    Termbox.clear()

    board = board |> Board.move |> Board.draw

    for {ch, x} <- Enum.with_index(String.to_charlist "(Press <q> to quit) #{length(board.lines)}") do
      :ok = Termbox.put_cell(%Cell{position: %Position{x: x, y: board.max_y}, ch: ch})
    end

    Termbox.present()

    quit = receive do
      {:event, %Event{ch: ?q}} -> true
    after
      @sleep -> false
    end

    loop(board, quit)
  end

  def run do
    :ok = Termbox.init()
    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())

    {:ok, width} = Termbox.width
    {:ok, height} = Termbox.height
    board = Board.new(width - 1, height - 1)
    
    loop(board, false)

    :ok = Termbox.shutdown()
  end
end
