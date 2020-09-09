defmodule Board.Server do
  @moduledoc """
  GenServer for managing the game board.
  """
  use GenServer

  ################################################################################
  # Client API.
  ################################################################################

  @doc """
  Create a new player in the Players.Server GenServer and store the PID in the Board.Server GenServer.
  """
  def add_player(player_name) do
    {:global, Game.player_pid(player_name)}
    |> GenServer.whereis()
    |> case do
      nil ->
        GenServer.call(__MODULE__, {:add_player, player_name})

      _ ->
        :ok
    end
  end

  @doc """
  Get the avatar out of the specified player's process.
  """
  def get_player_avatar(player_name) do
    GenServer.call({:global, Game.player_pid(player_name)}, :get_player_avatar)
  end

  @doc """
  Get the current position out of the specified player's process.
  """
  def get_player_position(player_name) do
    GenServer.call({:global, Game.player_pid(player_name)}, :get_player_position)
  end

  @doc """
  Get a list of all of the players' names from the Board.Server.
  """
  def get_players do
    GenServer.call(__MODULE__, :get_players)
  end

  @doc """
  Get a list of all the wall coodinates out of the Board.Server.
  """
  def get_walls do
    GenServer.call(__MODULE__, :get_walls)
  end

  @doc """
  Check to see if the specified player is alive.
  """
  def is_alive?(player_name) do
    GenServer.call({:global, Game.player_pid(player_name)}, :is_alive)
  end

  @doc """
  Check to see if the specified move is valid; i.e., it doesn't run you off the edge of the board
  or run you into a wall.
  """
  def is_move_valid?(move) do
    GenServer.call(__MODULE__, {:is_move_valid, move})
  end

  @doc """
  Kill the specifiec player. Dum, dum, dummmmmmmmm!!!
  """
  def kill_player(player_name) do
    GenServer.cast(__MODULE__, {:kill_player, player_name})
  end

  @doc """
  Kill the current Board.Server process and let the supervisor restart it, effectively
  starting a new game.
  """
  def restart_game do
    GenServer.call(__MODULE__, :restart)
  end

  @doc """
  Set the specified player's current position.
  """
  def set_player_position(player_name, position) do
    GenServer.cast({:global, Game.player_pid(player_name)}, {:set_player_position, position})
  end

  @doc """
  Start the Board.Server GenServer process.
  """
  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  ################################################################################
  # Server Callbacks.
  ################################################################################

  @impl true
  def init(_state) do
    state = %{
      walls: _generate_walls(),
      board: _generate_board(),
      players: [],
      available_avatars: [
        "./images/jayne.png",
        "./images/mal.png",
        "./images/zoe.png",
        "./images/wash.png",
        "./images/kaylee.png",
        "./images/inara.png"
      ]
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:add_player, player_name}, _from, state) do
    if state.available_avatars |> length > 0 do
      player = Game.player_pid(player_name)
      avatar = Enum.random(state.available_avatars)
      new_state = state
              |> Map.put(:available_avatars, Enum.filter(state.available_avatars, fn(a) -> a != avatar end))
              |> Map.put(:players, [ {:global, player} | state.players ])
      Game.start_player_link({player_name, avatar, _random_position(state.walls)})

      {:reply, :ok, new_state}
    else
      {:reply, :all_players_are_taken, state}
    end
  end

  @impl true
  def handle_call(:get_players, _from, state) do
    names = state.players
    |> Enum.reduce([], fn (player, acc) ->
      [ GenServer.call(player, :get_player_name) | acc ]
    end)

    {:reply, names, state}
  end

  @impl true
  def handle_call(:get_walls, _from, state) do
    {:reply, state.walls, state}
  end

  @impl true
  def handle_call({:is_move_valid, move}, _from, state) do
    {:reply, !Enum.member?(state.walls, move) && Enum.member?(state.board, move), state}
  end

  @impl true
  def handle_call(:restart, _from, state) do
    {:stop, :kill, :ok, state}
  end

  @impl true
  def handle_cast({:kill_player, player_name}, state) do
    GenServer.cast({:global, Game.player_pid(player_name)}, :kill_player)
    _resurrection_timer(player_name)
    {:noreply, state}
  end

  @impl true
  def handle_info({:resurrect_player, player_name}, state) do
    GenServer.cast({:global, Game.player_pid(player_name)}, {:resurrect_player, _random_position(state.walls)})
    {:noreply, state}
  end

  ################################################################################
  # Private Functions.
  ################################################################################

  defp _generate_board do
    for row <- 0..9,
      column <- 0..9,
      reduce: [] do
        acc -> [{row, column} | acc]
    end
    |> Enum.sort()
  end

  # Generate a bar-shaped wall and place it on the board randomly.
  defp _generate_shape(blocked, :bar) do
    row = Enum.random(0..9)
    column = Enum.random(0..7)

    [{row, column}, {row, column + 1}, {row, column + 2}]
    |> _test_for_collision(blocked, :bar)
  end

  # Generate a square-shaped wall and place it on the board randomly.
  defp _generate_shape(blocked, :square) do
    row = Enum.random(0..8)
    column = Enum.random(0..8)

    # Define the square's coordinates
    [{row, column}, {row, column + 1}, {row + 1, column}, {row + 1, column + 1}]
    |> _test_for_collision(blocked, :square)
  end

  # Generate a T-shaped wall and place it on the board randomly.
  defp _generate_shape(blocked, :cross) do
    row = Enum.random(0..7)
    column = Enum.random(0..7)

    [{row, column}, {row, column + 1}, {row, column + 2}, {row + 1, column + 1}, {row + 2, column + 1}]
    |> _test_for_collision(blocked, :cross)
  end

  # Generate all the walls.
  defp _generate_walls do
    MapSet.new([])
    |> _generate_shape(:square)
    |> _generate_shape(:cross)
    |> _generate_shape(:bar)
    |> MapSet.to_list()
  end

  # Resurrect dead players after 5 seconds.
  defp _resurrection_timer(player_name) do
    Process.send_after(self(), {:resurrect_player, player_name}, :timer.seconds(5))
  end

  defp _random_position(walls) do
    position = {Enum.random(0..9), Enum.random(0..9)}
    case Enum.member?(walls, position) do
      true ->
        _random_position(walls)

      false ->
        position
    end
  end

  defp _test_for_collision(wall, blocked, shape) do
    wall
    |> MapSet.new()
    |> MapSet.intersection(blocked)
    |> MapSet.size()
    |> case do
      0 ->
        MapSet.union(blocked, MapSet.new(wall))

      _ ->
        _generate_shape(blocked, shape)
    end
  end
end
