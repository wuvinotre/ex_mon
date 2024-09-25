defmodule ExMon do
  alias ExMon.{Player, Game}
  alias ExMon.Game.{Status, Actions}

  @computer_moves [:move_avg, :move_rnd, :move_heal]

  # player = ExMon.create_player(:tapa, :cura, :soco, "Vinicius")
  def create_player(move_avg, move_heal, move_rnd, name) do
    Player.build(move_avg, move_heal, move_rnd, name)
  end

  def start_game(player) do
    create_player(:punch, :heal, :kick, "Robot")
    |> Game.start(player)

    Status.print_round_message(Game.info())
  end

  def make_move(move) do
    Game.info()
    |> Map.get(:status)
    |> handle_status(move)
  end

  defp handle_status(:game_over, _move), do: Status.print_round_message(Game.info())

  defp handle_status(_other, move) do
    move
    |> Actions.fetch_move()
    |> do_move()

    computer_move(Game.info())
  end

  defp do_move({:error, move}), do: Status.print_wrong_move_message(move)

  defp do_move({:ok, move}) do
    case move do
      :move_heal ->
        Actions.heal()

      move ->
        Actions.attack(move)
    end

    Status.print_round_message(Game.info())
  end

  defp computer_move(%{turn: :computer, status: :continue}) do
    :computer
    |> Game.fetch_player()
    |> Map.get(:life)
    |> low_life_computer()
    |> do_move()
  end

  defp computer_move(_), do: :ok

  defp low_life_computer(life) when life < 40,
    do: {:ok, Enum.random([:move_heal | @computer_moves])}

  defp low_life_computer(_), do: {:ok, Enum.random(@computer_moves)}
end
