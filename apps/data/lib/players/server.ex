defmodule Players.Server do
  @moduledoc """
  GenServer for managing the players.
  """
  use GenServer

  ################################################################################
  # Client API.
  ################################################################################

  @doc """
  Generate a name for the specified player's Player PID, so it will be easy to access in
  both a stand-alone and clustered environment.
  """
  def player_pid(player_name) when is_binary(player_name) do
    "player_#{player_name}"
  end

  @doc """
  Start a new Players.Server process for the specified player.
  """
  def start_link({player_name, avatar, position}) when is_binary(player_name) and is_binary(avatar) and is_tuple(position) do
    GenServer.start_link(__MODULE__, {player_name, avatar, position}, name: {:global, player_pid(player_name)})
  end

  ################################################################################
  # Server Callbacks.
  ################################################################################

  @impl true
  def init({player_name, avatar, position}) do
    state = %{
      alive: true,
      avatar: avatar,
      living_avatar: avatar,
      name: player_name,
      position: position
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_player_avatar, _from, state) do
    {:reply, state.avatar, state}
  end

  @impl true
  def handle_call(:get_player_name, _from, state) do
    {:reply, state.name, state}
  end

  @impl true
  def handle_call(:get_player_position, _from, state) do
    {:reply, state.position, state}
  end

  @impl true
  def handle_call(:is_alive, _from, state) do
    {:reply, state.alive, state}
  end

  @impl true
  def handle_cast(:kill_player, state) do
    {:noreply, %{ state | avatar: "./images/dead.svg", alive: false}}
  end

  @impl true
  def handle_cast({:resurrect_player, position}, state) do
    {:noreply, %{ state | position: position, avatar: state.living_avatar, alive: true}}
  end

  @impl true
  def handle_cast({:set_player_position, position}, state) do
    {:noreply, %{ state | position: position}}
  end

  ################################################################################
  # Private Functions.
  ################################################################################
end
