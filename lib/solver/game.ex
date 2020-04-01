defmodule Game do
  def run(final_board, 0, tPid, _acc) do
    #Send stuff to tracker
    send(tPid, {:solved, final_board})
    # starting_board
  end

  def run(starting_board, num_generations, tPid, acc \\ 0) do
    #send stuff to tracker
    send(tPid, {:progress, acc})

    # calculates the final state of the board after num_generations turns
    run(Board.advance(starting_board), num_generations-1, tPid, acc + 1)


  end

end
