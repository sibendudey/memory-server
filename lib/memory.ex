defmodule Memory.Game do
  #  @moduledoc """
  #  Memory keeps the contexts that define your domain
  #  and business logic.
  #
  #  Contexts are also responsible for managing your data, regardless
  #  if it comes from the database, an external API or others.
  #  """

  def new do
    %{
      :score => 0,
      :arrayElements => [
        [
          %{value: "A", display: false},
          %{value: "D", display: false},
          %{value: "H", display: false},
          %{value: "G", display: false}
        ],
        [
          %{value: "B", display: false},
          %{value: "D", display: false},
          %{value: "E", display: false},
          %{value: "F", display: false}
        ],
        [
          %{value: "F", display: false},
          %{value: "H", display: false},
          %{value: "A", display: false},
          %{value: "B", display: false}
        ],
        [
          %{value: "C", display: false},
          %{value: "E", display: false},
          %{value: "G", display: false},
          %{value: "C", display: false}
        ]
      ],
      :clickable => true
    }

  end

  def client_view(game) do
    game
  end

  def nextState(game, key, true) do
    IO.inspect game
    IO.inspect key
    arrayElements = Map.get(game, :arrayElements)
    index1 = Map.get(Map.get(key, "location"), "i")
    index2 = Map.get(Map.get(key, "location"), "i")
    IO.inspect index1
    IO.inspect index2

    arrayElements = arrayElements
                    |> Enum.with_index
                    |> Enum.map (fn {x, i} -> if (i == index1) do
                                                x
        |> Enum.with_index
        |> Enum.map(
             fn {y, j} ->
               if (j == index2) do
                 Map.update!(y, :display, fn (x) -> x == false end)
               else
                 y
               end
             end
           )
      else
        x
      end
                                 end)

    #    j = Map.get(Map.get(key, :location), :j)
    #    element[j].push(%{value: Map.get(Map.get(key, :tile), :value), display: true})
    #    IO.puts element[j]
    Map.update!(game, :arrayElements, fn (x) -> arrayElements end)
    |> Map.update(:prev, key, fn (x) -> x end)
  end

  def nextState(game, key, false) do
    IO.inspect game
    IO.inspect key
    arrayElements = Map.get(game, :arrayElements)
    index1 = Map.get(Map.get(key, "location"), "i")
    index2 = Map.get(Map.get(key, "location"), "i")
    IO.inspect index1

    arrayElements = arrayElements
                    |> Enum.with_index
                    |> Enum.map (fn {x, i} ->
      if (i == index1) do
        x
        |> Enum.with_index
        |> Enum.map(
             fn {y, j} ->
               if (j == index2) do
                 Map.update!(y, :display, fn (x) -> x == false end)
               else
                 y
               end
             end
           )
      else
        x
      end
                                 end)

    #    j = Map.get(Map.get(key, :location), :j)
    #    element[j].push(%{value: Map.get(Map.get(key, :tile), :value), display: true})
    #    IO.puts element[j]
    Map.update!(game, :arrayElements, fn (x) -> arrayElements end)
    |> Map.delete(:prev)
  end
end