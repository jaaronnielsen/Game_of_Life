defmodule GameOfLifeTest do
  use ExUnit.Case

  # # describe "Cell.get_neighbors" do
  # #   test "Translate Coordinates" do
  # #     actual = Board.translate(1, -1)
  # #     expected = 0
  # #     assert expected == actual
  # #   end


  #   test "Find neighbors for 1,1" do
  #     cell = %Cell{x: 1, y: 1}
  #     actual_neighbors =
  #       Board.get_neighbors(cell)
  #       |> Enum.sort
  #     expected_neighbors = [
  #       %Cell{x:  1, y:  2},
  #       %Cell{x:  2, y:  2},
  #       %Cell{x:  2, y:  1},
  #       %Cell{x: 0, y:  2},
  #       %Cell{x: 0, y:  1},
  #       %Cell{x: 0, y: 0},
  #       %Cell{x:  1, y: 0},
  #       %Cell{x:  2, y: 0}
  #     ] |> Enum.sort
  #     assert expected_neighbors == actual_neighbors
  #   end
  # end

  test "Count live neighbors" do
    cell = %Cell{x: 1, y: 1}
    starting_board = [cell]
    actual = Board.count_live(starting_board, cell)
    expected = 0
    assert expected == actual
  end

  describe "Board.advance/1" do
    test "Rule 1: any adjacent cell with fewer than two neighbors dies as if by underpopulation" do
      starting_board = [%Cell{x: 1, y: 1}]
      actual_board = Board.advance(starting_board)
      expected_board = []

      assert expected_board == actual_board
      #, "All cells should die as if by underpopulation"
    end

    test "Rule 2: any live cell with two or three neighbors lives on to the next generation" do
      starting_board = [%Cell{x: 1, y: 1}, %Cell{x: 2, y: 1}, %Cell{x: 1, y: 2}]
      actual_board = Board.advance(starting_board)
      expected_board = [%Cell{x: 1, y: 1}, %Cell{x: 2, y: 1}, %Cell{x: 1, y: 2}, %Cell{x: 2, y: 2}]

      assert Enum.sort(expected_board) == Enum.sort(actual_board)
    end

    # ## Test 3ish, this will fail if the game is played correctly
    # test "Making sure the right things die" do
    #   starting_board = [
    #                       %Cell{x: 2, y: 4}, %Cell{x: 3, y: 4}, %Cell{x: 4, y: 4},
    #                       %Cell{x: 2, y: 3}, %Cell{x: 3, y: 3}, %Cell{x: 4, y: 3},
    #                       %Cell{x: 2, y: 2}, %Cell{x: 3, y: 2}, %Cell{x: 4, y: 2},
    #   ]

    #   expected_board = [
    #                       %Cell{x: 2, y: 4},                    %Cell{x: 4, y: 4},

    #                       %Cell{x: 2, y: 2},                    %Cell{x: 4, y: 2},
    #   ]

    #   actual_board = Board.advance(starting_board)

    #   assert Enum.sort(expected_board) == Enum.sort(actual_board)
    # end

    test "Rule 3: any live cell with more than three neighbors dies, as if by overpopulation" do
      starting_board = [
                          %Cell{x: 2, y: 4}, %Cell{x: 3, y: 4}, %Cell{x: 4, y: 4},
                          %Cell{x: 2, y: 3}, %Cell{x: 3, y: 3}, %Cell{x: 4, y: 3},
                          %Cell{x: 2, y: 2}, %Cell{x: 3, y: 2}, %Cell{x: 4, y: 2},
      ]

      expected_board = [
                                              %Cell{x: 3, y: 5},
                           %Cell{x: 2, y: 4},                    %Cell{x: 4, y: 4},
        %Cell{x: 1, y: 3},                                                          %Cell{x: 5, y: 3},
                           %Cell{x: 2, y: 2},                    %Cell{x: 4, y: 2},
                                              %Cell{x: 3, y: 1},
      ]
      actual_board = Board.advance(starting_board)

      assert Enum.sort(expected_board) == Enum.sort(actual_board)
    end

    test "Rule 4: any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction" do
      starting_board = [%Cell{x: 1, y: 1}, %Cell{x: 3, y: 1}, %Cell{x: 1, y: 3}]
      expected_board = [%Cell{x: 2, y: 2}]

      actual_board = Board.advance(starting_board)

      assert Enum.sort(expected_board) == Enum.sort(actual_board)
    end
  end

  test "Check run function" do
    starting_board = [%Cell{x: 1, y: 1}, %Cell{x: 2, y: 1}, %Cell{x: 1, y: 2}]
    actual_board = Game.run(starting_board, 10)
    expected_board = [%Cell{x: 1, y: 1}, %Cell{x: 2, y: 1}, %Cell{x: 1, y: 2}, %Cell{x: 2, y: 2}]

      assert Enum.sort(expected_board) == Enum.sort(actual_board)
  end

  describe "Game.run/2" do
    test "Test all steps" do
      starting_board = [%Cell{x: 3, y: -4},%Cell{x: 4, y: -7},%Cell{x: 5, y: -6},%Cell{x: 6, y: -7},%Cell{x: 6, y: -5},%Cell{x: 6, y: -4},%Cell{x: 7, y: -8},%Cell{x: 7, y: -7},%Cell{x: 7, y: -6},%Cell{x: 8, y: -7},%Cell{x: 8, y: -6},%Cell{x: 9, y: -5}]
      actual_board = Game.run(starting_board, 10)
      expected_board = [%Cell{x: 4, y: -8},%Cell{x: 2, y: -8},%Cell{x: 4, y: -7},%Cell{x: 5, y: -6},%Cell{x: 1, y: -7},%Cell{x: 1, y: -6},%Cell{x: 1, y: -5},%Cell{x: 2, y: -5},%Cell{x: 5, y: -5},%Cell{x: 5, y: -4},%Cell{x: 4, y: -3},%Cell{x: 3, y: -4},%Cell{x: 7, y: -5},%Cell{x: 7, y: -6},%Cell{x: 8, y: -4},%Cell{x: 7, y: -4},%Cell{x: 9, y: -6},%Cell{x: 9, y: -5},%Cell{x: 9, y: -7}]
      assert Enum.sort(expected_board) == Enum.sort(actual_board), "Testing whole app"
    end
  end
end
