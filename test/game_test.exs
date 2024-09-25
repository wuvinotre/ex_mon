defmodule ExMon.GameTest do
  use ExUnit.Case
  alias ExMon.{Game, Player}

  describe "start/2" do
    test "starts the game state" do
      player = Player.build(:tapa, :cura, :soco, "Vinicius")
      computer = Player.build(:tapa, :cura, :soco, "Robot")

      assert {:ok, _pid} = Game.start(computer, player)
    end
  end

  describe "info/0" do
    test "returns the current game state" do
      player = Player.build(:tapa, :cura, :soco, "Vinicius")
      computer = Player.build(:tapa, :cura, :soco, "Robot")
      Game.start(computer, player)
      starting_player = Game.info() |> Map.get(:turn)

      expected = %{
        status: :started,
        player: %Player{
          life: 100,
          moves: %{move_avg: :tapa, move_heal: :cura, move_rnd: :soco},
          name: "Vinicius"
        },
        computer: %Player{
          life: 100,
          moves: %{move_avg: :tapa, move_heal: :cura, move_rnd: :soco},
          name: "Robot"
        },
        turn: starting_player
      }

      assert expected == Game.info()
    end
  end

  describe "update/1" do
    test "return the game state updated" do
      player = Player.build(:tapa, :cura, :soco, "Vinicius")
      computer = Player.build(:tapa, :cura, :soco, "Robot")
      Game.start(computer, player)
      starting_player = Game.info() |> Map.get(:turn)

      state = %{
        status: :started,
        player: %Player{
          life: 100,
          moves: %{move_avg: :tapa, move_heal: :cura, move_rnd: :soco},
          name: "Vinicius"
        },
        computer: %Player{
          life: 100,
          moves: %{move_avg: :tapa, move_heal: :cura, move_rnd: :soco},
          name: "Robot"
        },
        turn: starting_player
      }

      assert state == Game.info()

      new_state = %{
        status: :started,
        player: %Player{
          life: 50,
          moves: %{move_avg: :tapa, move_heal: :cura, move_rnd: :soco},
          name: "Vinicius"
        },
        computer: %Player{
          life: 85,
          moves: %{move_avg: :tapa, move_heal: :cura, move_rnd: :soco},
          name: "Robot"
        },
        turn: starting_player
      }

      Game.update(new_state)

      new_starting_player = Game.info() |> Map.get(:turn)

      # left?
      expected = %{new_state | turn: new_starting_player, status: :continue}

      assert expected == Game.info()
    end
  end

  describe "player/0" do
    test "returns the current player" do
      player = Player.build(:tapa, :cura, :soco, "Vinicius")
      computer = Player.build(:tapa, :cura, :soco, "Robot")
      Game.start(computer, player)

      expected = %Player{
        life: 100,
        moves: %{move_avg: :tapa, move_heal: :cura, move_rnd: :soco},
        name: "Vinicius"
      }

      assert expected == Game.player()
    end
  end

  describe "turn/0" do
    test "returns the current turn" do
      player = Player.build(:tapa, :cura, :soco, "Vinicius")
      computer = Player.build(:tapa, :cura, :soco, "Robot")
      Game.start(computer, player)
      starting_player = Game.info() |> Map.get(:turn)

      assert starting_player == Game.turn()
    end
  end

  describe "fetch_player/1" do
    player = Player.build(:tapa, :cura, :soco, "Vinicius")
    computer = Player.build(:tapa, :cura, :soco, "Robot")
    Game.start(computer, player)

    expected_player = %Player{
      life: 100,
      moves: %{move_avg: :tapa, move_rnd: :soco, move_heal: :cura},
      name: "Vinicius"
    }

    expected_computer = %Player{
      life: 100,
      moves: %{move_avg: :tapa, move_heal: :cura, move_rnd: :soco},
      name: "Robot"
    }

    assert expected_player == Game.fetch_player(:player)
    assert expected_computer == Game.fetch_player(:computer)
  end
end
