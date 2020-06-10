defmodule Board.ServerTest do
  use ExUnit.Case
  doctest Data

  alias Board.Server, as: BS

  describe "test the happy-paths for the Client APIs for the Board.Server GenServer" do
    test "add_player/1 and get_players/0" do
      player = "phil_myman"
      BS.add_player(player)
      assert Enum.member?(BS.get_players(), player)
    end

    test "get_player_avatar/1" do
      player = "phil_myman"
      BS.add_player(player)
      assert String.match?(BS.get_player_avatar(player), ~r/image/)
    end

    test "get_walls/0" do
      BS.add_player("phil_myman")
      walls = BS.get_walls()
      assert is_list(walls)
      assert length(walls) > 0
    end

    test "is_alive?/1 and kill_player/1 and player resurrection" do
      player = "phil_myman"
      BS.add_player(player)
      assert BS.is_alive?(player)

      BS.kill_player(player)
      refute BS.is_alive?(player)

      :timer.sleep(5500)

      assert BS.is_alive?(player)
    end

    test "restart_game/0" do
      player = "phil_myman"
      BS.add_player(player)
      assert Enum.member?(BS.get_players(), player)

      BS.restart_game

      :timer.sleep(1000)

      refute Enum.member?(BS.get_players(), "phil_myman")
    end

    test "set_player_position/2 and get_player_position/1" do
      player = "phil_myman"
      BS.add_player(player)
      BS.set_player_position(player, {1, 1})
      assert BS.get_player_position(player) == {1, 1}
    end
  end
end

