defmodule GameClient do
 @moduledoc """
  Start game of life server by running the following command:

  docker pull snowcollege/gameoflife-server
  docker run -it --rm -p 0.0.0.0:80:80 snowcollege/gameoflife-server

  """
  alias HTTPoison

  def game do
    {:ok, guid} = register("http://144.17.48.51","MARCELOOOOO")
    guid
  end

  #Gets token from user and spawns update and tracker processes
  def register(endpoint, name) do

    #Getting token from server
    HTTPoison.start

    body = Poison.encode!(%{name: name})
    headers = [{"Content-type", "application/json"}]

    #Filtering response to get the token
    case HTTPoison.post!(endpoint<>"/register", body, headers) do

      %HTTPoison.Response{status_code: 500} ->
        register(endpoint, name <> "_1")

      %HTTPoison.Response{status_code: 200, body: body} ->
        body
        |> Poison.decode
        |> case do
          {:ok, %{"token" => token}}
            -> {:ok, token}
               #Creation of Tracker and Update Processes
              tPid = spawn(fn -> tracker(0, nil) end)
              _uPid = spawn(fn -> started_yet(token, endpoint, tPid) end)
          _
            -> {:error, "Unable to identify token in 200 response"}
        end

      _ ->
        {:error, "Unable to parse response"}
    end
    # #receive block for the server response.
    # body = Poison.encode!(-)
  end

  #Keeps track of current board processed by solver
  def tracker(numGen, board) do
    #Process.sleep(1_000)
    receive do
        {:getStatus, cPid} ->
          #IO.puts("In tracker :getStatus")
          case board do
            nil -> send(cPid, {:progress, numGen})
                  tracker(numGen, board)
            _ -> send(cPid, {:completed, numGen, board})
          end
        {:progress, numGen} ->
          IO.puts(numGen)
          tracker(numGen, board)
        {:solved, final_board} ->
          tracker(numGen + 1, final_board)
    end
  end

  #waits for game to start
  #once the game began, it talks to the server every second sending board and generations computed.
  def started_yet(token, endpoint, tPid) do
    Process.sleep(500)
    body = Poison.encode!(%{token: token})         #Talk to server sending the update
    headers = [{"content-type", "application/json"}]                            #of the generations computed

    case HTTPoison.post!(endpoint <> "/update", body, headers) do
      %HTTPoison.Response{status_code: 200, body: body} ->
        body
        |> Poison.decode
        #|> IO.inspect()
        |> case do
          {:ok, %{"generationsToCompute" => genNum ,"seedBoard" => board}} ->
            #something
            case board do
              nil ->                                         #Board is empty, so game hasnt began
                IO.puts("waiting for game to start")
                started_yet(token, endpoint, tPid)
              _ ->
                  cells =
                    board |> Enum.map(fn c -> %Cell{x: c["x"], y: c["y"]} end)                 #Board is received, but not passed to solver
                  _solverPid = spawn(fn -> Game.run(cells, genNum, tPid) end)
                  _cPid = spawn(fn -> check_up(token, endpoint, tPid) end)
            end
          _ ->
            {:error, "Sorry bro"}
        end
    end
  end


  def check_up(token, endpoint, tPid) do
    send(tPid, {:getStatus, self()})
    #IO.puts("In Checkup")

    receive do
      {:progress, numGen} ->
        #IO.puts(numGen)                                                         #Got the message progress
        body = Poison.encode!(%{token: token, generationsComputed: numGen})         #Talk to server sending the update
        headers = [{"content-type", "application/json"}]                            #of the generations computed
        HTTPoison.post!(endpoint <> "/update", body, headers)

      {:completed, numGen, finalBoard} ->
        #IO.puts("In Checkup Receive, :completed")
        result_board = Enum.map(finalBoard, fn c -> %{"x" => c.x, "y" => c.y} end)                                    #Got the message completed
        finalbody = Poison.encode!(%{token: token,                                  #Send final board and number of
                      generationsComputed: numGen, resultBoard: result_board})         #generations to the server
        finalheaders = [{"content-type", "application/json"}]                       #End of program
        HTTPoison.post!(endpoint <> "/update", finalbody, finalheaders)
        IO.puts("I'm done!")
    end
    #Process.sleep(500)
    check_up(token, endpoint, tPid)
  end

end
