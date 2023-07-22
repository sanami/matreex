defmodule Matreex do
  use GenServer, restart: :temporary

  alias ExTermbox.Bindings, as: Termbox
  alias ExTermbox.{Cell, EventManager, Event, Position}
  alias Matreex.Board

  @me __MODULE__
  @sleep 40

  def start_link(_) do
    GenServer.start_link(@me, [], name: @me)
  end

  @impl true
  def init(_init_arg) do
    :ok = Termbox.init()

    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())

    {:ok, width} = Termbox.width
    {:ok, height} = Termbox.height
    board = Board.new(width - 1, height - 1)
    state = %{board: board, sleep: @sleep, quit: false}

    Process.send_after(@me, :loop, 0)
    
    {:ok, state}
  end

  @impl true
  def handle_info(:loop, state) do
    new_state = loop(state)
    Process.send_after(@me, :loop, new_state.sleep)

    {:noreply, new_state}
  end

  @impl true
  def handle_info({:event, %Event{ch: ?-}}, state) do
    {:noreply, %{state | sleep: state.sleep + 10}}
  end

  @impl true
  def handle_info({:event, %Event{ch: ?=}}, %{sleep: sleep} = state) do
    sleep = if sleep >= 20, do: sleep - 10, else: sleep
    {:noreply, %{state | sleep: sleep}}
  end

  @impl true
  def handle_info({:event, %Event{ch: ?q}}, state) do
    :ok = Termbox.shutdown()
    System.stop(0)
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:event, ev}, state), do: {:noreply, state}

  # Internal
  def loop(state) do
    Termbox.clear()
    board = state.board |> Board.move |> Board.draw
    print 0, board.max_y, "(Press <q> to quit) #{state.sleep} #{length(board.lines)}"
    Termbox.present()

    %{state | board: board}
  end

  def print(x, y, str) when is_binary(str) do
    str
    |> String.to_charlist
    |> Stream.with_index
    |> Enum.each(fn {ch, xx} ->
      Termbox.put_cell(%Cell{position: %Position{x: x+xx, y: y}, ch: ch})
    end)
  end
end
