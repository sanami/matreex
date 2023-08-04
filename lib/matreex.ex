defmodule Matreex do
  use GenServer, restart: :temporary

  alias ExTermbox.Bindings, as: Termbox
  alias ExTermbox.{EventManager, Event}
  alias Matreex.{Board, Render}

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
      add_count: 1, # div(width, height) + 1,
      pause: false,
      bold: true,
      words: true
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
  def handle_info({:event, %Event{ch: ch}}, state) when ch == ?q do
    :ok = Termbox.shutdown()
    # System.stop(0)
    System.halt(0)
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:event, ev}, state) do
    {:noreply, process_key(ev, state)}
  end

  # Internal
  def process_key(%Event{ch: ch, key: key}, state) do
    cond do
      key == ?\s ->
        %{state | pause: !state.pause}
      ch == ?b ->
        %{state | bold: !state.bold}
      ch == ?w ->
        %{state | words: !state.words}
      ch in [?-, ?=, ?+] ->
        change_sleep(state, ch == ?-)
      ch in ?1..?9 ->
        add_count = String.to_integer <<ch>>
        %{state | add_count: add_count}
      true ->
        state
    end
  end

  def loop(state) do
    Termbox.clear()

    board = if state.pause, do: state.board, else: Board.move(state.board, state.add_count, state.words)
    Board.draw(board, state.bold)

    Render.print(0, board.max_y, "Quit")
    Render.print(5, board.max_y, "Words", state.words)
    Render.print(11, board.max_y, "Bold", state.bold)
    Render.print(16, board.max_y, "#{state.add_count}", true)
    Render.print(18, board.max_y, "-#{state.sleep}+ #{length(board.lines)}")
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
end
