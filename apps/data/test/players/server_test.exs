defmodule Players.ServerTest do
  use ExUnit.Case
  doctest Players.Server

  alias Players.Server, as: PS

  describe "test the happy-paths for the Client APIs for the Players.Server GenServer" do
    test "player_pid/1" do
      assert PS.player_pid("phil_myman") == "player_phil_myman"
    end
  end
end
