defmodule Board do
  defstruct livecells: []

  def advance(current_board) do
    # calculates the next state of the board
    Enum.concat(
      potential_live_cells(current_board)
        |> Enum.filter(fn c ->
          count_live(current_board, c) == 3
      end),

      current_board
      |> Enum.filter(fn c ->
        count_live(current_board, c)
        |> cell_fate
      end)
    )
    |> Enum.uniq
  end

  def cell_fate(num_live_neighbors) when num_live_neighbors > 1 and num_live_neighbors < 4 do
    true
  end

  def cell_fate(_) do
    false
  end

  def count_live(board, cell = %Cell{}) do
    get_neighbors(cell)
    |> Enum.count(fn n ->
      Enum.member?(board, n)
    end)
  end

  def potential_live_cells(board) do
    board
    |> Enum.map(fn c ->
      get_neighbors(c)
    end)
      |> Enum.concat
        |> Enum.uniq
  end

  def get_neighbors(%Cell{x: x, y: y} = _cell) do
    [
     %Cell{x: x-1, y: y+1},
     %Cell{x:   x, y: y+1},
     %Cell{x: x+1, y: y+1},
     %Cell{x: x+1, y:   y},
     %Cell{x: x+1, y: y-1},
     %Cell{x:   x, y: y-1},
     %Cell{x: x-1, y: y-1},
     %Cell{x: x-1, y:   y}
    ]
  end

end
