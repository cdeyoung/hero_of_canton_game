defmodule Board.Supervisor do
  @moduledoc """
  Supervisor for managing the game server processes.
  """
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Board.Server
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
