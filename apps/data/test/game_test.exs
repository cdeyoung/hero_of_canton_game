defmodule GameTest do
  use ExUnit.Case

  describe "test the happy-paths for the Client APIs for the Players.Server GenServer" do
    test "player_pid/1" do
      assert Game.player_pid("phil_myman") == "player_phil_myman"
    end
  end

  describe "test the happy-paths for the Client APIs for the Board.Server GenServer" do
    test "add_player/1 and get_players/0" do
      player = "phil_myman"
      Game.add_player(player)
      assert Enum.member?(Game.get_players(), player)
    end

    test "get_player_avatar/1" do
      player = "phil_myman"
      Game.add_player(player)
      assert String.match?(Game.get_player_avatar(player), ~r/image/)
    end

    test "get_walls/0" do
      Game.add_player("phil_myman")
      walls = Game.get_walls()
      assert is_list(walls)
      assert length(walls) > 0
    end

    test "is_alive?/1 and kill_player/1 and player resurrection" do
      player = "phil_myman"
      Game.add_player(player)
      assert Game.is_alive?(player)

      Game.kill_player(player)
      refute Game.is_alive?(player)

      :timer.sleep(5500)

      assert Game.is_alive?(player)
    end

    test "restart_game/0" do
      player = "phil_myman"
      Game.add_player(player)
      assert Enum.member?(Game.get_players(), player)

      Game.restart_game

      :timer.sleep(1000)

      refute Enum.member?(Game.get_players(), "phil_myman")
    end

    test "set_player_position/2 and get_player_position/1" do
      player = "phil_myman"
      Game.add_player(player)
      Game.set_player_position(player, {1, 1})
      assert Game.get_player_position(player) == {1, 1}
    end
  end
end
