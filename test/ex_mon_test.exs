defmodule ExMonTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias ExMon.{Game, Player}

  describe "create_player/4" do
    test "returns a player" do
      expected = %Player{
        life: 100,
        moves: %{move_avg: :tapa, move_heal: :cura, move_rnd: :soco},
        name: "Vinicius"
      }

      assert expected == ExMon.create_player(:tapa, :cura, :soco, "Vinicius")
    end
  end

  describe "start_game/1" do
    test "when the game is started, returns a message" do
      player = Player.build(:tapa, :cura, :soco, "Vinicius")

      messages =
        capture_io(fn ->
          assert ExMon.start_game(player) == :ok
        end)

      starting_player = Game.info() |> Map.get(:turn)

      assert messages =~ "The game is started!"
      assert messages =~ "status: :started"
      assert messages =~ "turn: :#{starting_player}"
    end
  end

  describe "make_move/1" do
    setup do
      player = Player.build(:soco, :cura, :chute, "Vinicius")

      capture_io(fn ->
        ExMon.start_game(player)
      end)

      :ok
    end

    test "when the move is valid, do the move and the computer makes a move" do
      messages =
        capture_io(fn ->
          assert ExMon.make_move(:chute)
        end)

      assert messages =~ "The Player attacked the computer" or "The Computer attacked the player"
      assert messages =~ "It's computer turn." or "It's player turn."
      assert messages =~ "It's player turn"
      assert messages =~ "status: :continue"
    end

    test "when the move is invalid, return an error message" do
      messages =
        capture_io(fn ->
          assert ExMon.make_move(:tapa)
        end)

      assert messages =~ "Invalid move: tapa."
    end

    test "when the game ends and there is movement, return the game over message" do
      starting_player = Game.info() |> Map.get(:turn)

      state = %{
        status: :game_over,
        player: %Player{
          life: 50,
          moves: %{move_avg: :tapa, move_heal: :cura, move_rnd: :soco},
          name: "Vinicius"
        },
        computer: %Player{
          life: 0,
          moves: %{move_avg: :tapa, move_heal: :cura, move_rnd: :soco},
          name: "Robot"
        },
        turn: starting_player
      }

      messages =
        capture_io(fn ->
          assert Game.update(state)
          assert ExMon.make_move(:soco)
        end)

      assert messages =~ "The game is over"
    end
  end
end
