defmodule Web.GameLive do
  use Web, :live_view

  alias Board.Server, as: BS

  ################################################################################
  # LiveView Callbacks.
  ################################################################################

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    {:ok, assign(socket, player: nil, players: _update_players_data(), walls: BS.get_walls())}
  end

  @impl true
  def handle_event("add-player", %{"add-player" => player_name}, socket) do
    case BS.add_player(player_name) do
      :ok ->
        {:noreply, assign(socket, players: _update_players_data(), player: player_name)}

      :all_players_are_taken ->
        new_socket = socket
        |> put_flash(:info, "All the characters are currently being played. Please try again later.")
        {:noreply, new_socket}
    end
  end

  @impl true
  def handle_event("attack", %{"row" => row, "column" => column}, socket) do
    case BS.is_alive?(socket.assigns.player) do
      true ->
        {row, column} = _convert_coordinates_to_int(row, column)
        attack = [
          {row - 1, column - 1}, {row - 1, column}, {row - 1, column + 1},
          {row, column - 1}, {row, column}, {row, column + 1},
          {row + 1, column - 1}, {row + 1, column}, {row + 1, column + 1}
        ]

        socket.assigns.players
        |> Map.keys()
        |> Enum.each(fn(player) ->
          if player != socket.assigns.player && Enum.member?(attack, socket.assigns.players[player].position) do
            BS.kill_player(player)
          end
        end)

        {:noreply, assign(socket, players: _update_players_data())}

      false ->
        {:noreply, assign(socket, players: _update_players_data())}
    end
  end

  @impl true
  def handle_event("move", %{"row" => row, "column" => column}, socket) do
    position = _convert_coordinates_to_int(row, column)
    case BS.is_alive?(socket.assigns.player) && BS.is_move_valid?(position) do
      true ->
        BS.set_player_position(socket.assigns.player, position)
        {:noreply, assign(socket, players: _update_players_data())}

      false ->
        {:noreply, assign(socket, players: _update_players_data())}
    end
  end

  @impl true
  def handle_event("restart", _, socket) do
    BS.restart_game()
    {:noreply, assign(socket, player: nil, players: %{}, walls: BS.get_walls())}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, assign(socket, players: _update_players_data())}
  end

  ################################################################################
  # Private Functions.
  ################################################################################

  defp _convert_coordinates_to_int(row, column) do
    {String.to_integer(row), String.to_integer(column)}
  end

  defp _update_players_data do
    BS.get_players()
    |> Enum.reduce(%{}, fn(player, acc) ->
      acc
      |> put_in(Enum.map([player, :position], &Access.key(&1, %{})), BS.get_player_position(player))
      |> put_in(Enum.map([player, :avatar], &Access.key(&1, %{})), BS.get_player_avatar(player))
    end)
  end
end
