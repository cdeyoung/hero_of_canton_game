defmodule Game do
  @defmodule """
  Context for the game.
  """
  alias Board.Server, as: BS
  alias Players.Server, as: PS

  @doc """
  Create a new player in the Players.Server GenServer and store the PID in the Board.Server GenServer.
  """
  def add_player(player_name) do
    BS.add_player(player_name)
  end

  @doc """
  Get the avatar out of the specified player's process.
  """
  def get_player_avatar(player_name) do
    BS.get_player_avatar(player_name)
  end

  @doc """
  Get the current position out of the specified player's process.
  """
  def get_player_position(player_name) do
    BS.get_player_position(player_name)
  end

  @doc """
  Get a list of all of the players' names from the Board.Server.
  """
  def get_players do
    BS.get_players()
  end

  @doc """
  Get a list of all the wall coodinates out of the Board.Server.
  """
  def get_walls do
    BS.get_walls()
  end

  @doc """
  Check to see if the specified player is alive.
  """
  def is_alive?(player_name) do
    BS.is_alive?(player_name)
  end

  @doc """
  Check to see if the specified move is valid; i.e., it doesn't run you off the edge of the board
  or run you into a wall.
  """
  def is_move_valid?(move) do
    BS.is_move_valid?(move)
  end

  @doc """
  Kill the specifiec player. Dum, dum, dummmmmmmmm!!!
  """
  def kill_player(player_name) do
    BS.kill_player(player_name)
  end

  @doc """
  Kill the current Board.Server process and let the supervisor restart it, effectively
  starting a new game.
  """
  def restart_game do
    BS.restart_game()
  end

  @doc """
  Set the specified player's current position.
  """
  def set_player_position(player_name, position) do
    BS.set_player_position(player_name, position)
  end

  @doc """
  Start the Board.Server GenServer process.
  """
  def start_board_link(args) do
    BS.start_link(args)
  end

  @doc """
  Generate a name for the specified player's Player PID, so it will be easy to access in
  both a stand-alone and clustered environment.
  """
  def player_pid(player_name) when is_binary(player_name) do
    PS.player_pid(player_name)
  end

  @doc """
  Start a new Players.Server process for the specified player.
  """
  def start_player_link({player_name, avatar, position}) when is_binary(player_name) and is_binary(avatar) and is_tuple(position) do
    PS.start_link({player_name, avatar, position})
  end
end
