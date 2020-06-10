defmodule Data do
  @moduledoc """
  Backend data application for game logic.
  """
  use Application

  def start(_type, _args) do
    IO.puts("Starting the game server.")
    Board.Supervisor.start_link()
  end
end
