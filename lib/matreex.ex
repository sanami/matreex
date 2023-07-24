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
    state = %{
      board: board,
      sleep: @sleep,
      add_count: div(width, height) + 1 
    }

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
  def handle_info({:event, %Event{ch: ch}}, state) when ch in [?q, ?й] do
    :ok = Termbox.shutdown()
#    System.stop(0)
    System.halt(0)
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:event, %Event{ch: ch}}, state) when ch in [?-, ?=, ?+] do
    {:noreply, change_sleep(state, ch == ?-)}
  end

  @impl true
  def handle_info({:event, %Event{ch: ch}}, state) when ch in ?1..?9 do
    add_count = String.to_integer <<ch>>
    {:noreply, %{state | add_count: add_count}}
  end

  @impl true
  def handle_info({:event, _ev}, state), do: {:noreply, state}

  # Internal
  def loop(state) do
    Termbox.clear()
    board = state.board |> Board.move(state.add_count) |> Board.draw
    print 0, board.max_y, "(Press <q> to quit) #{state.add_count} #{state.sleep} #{length(board.lines)}"
    Termbox.present()

    %{state | board: board}
  end

  def change_sleep(%{sleep: sleep} = state, inc) do
    sleep = cond do
      inc -> sleep + 10
      sleep >= 10 -> sleep - 10
      true -> sleep
    end

    %{state | sleep: sleep}
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
