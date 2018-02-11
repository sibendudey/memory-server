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
      :arrayElements => Enum.shuffle(
        [
          Enum.shuffle(
            [
              %{value: "A", display: false},
              %{value: "D", display: false},
              %{value: "H", display: false},
              %{value: "G", display: false}
            ]
          ),
          Enum.shuffle(
            [
              %{value: "B", display: false},
              %{value: "D", display: false},
              %{value: "E", display: false},
              %{value: "F", display: false}
            ]
          ),
          Enum.shuffle(
            [
              %{value: "F", display: false},
              %{value: "H", display: false},
              %{value: "A", display: false},
              %{value: "B", display: false}
            ]
          ),
          Enum.shuffle(
            [
              %{value: "C", display: false},
              %{value: "E", display: false},
              %{value: "G", display: false},
              %{value: "C", display: false}
            ]
          )
        ]
      ),
      :clickable => true
    }

  end

  def nextState(game, key, true) do
    arrayElements = Map.get(game, :arrayElements)
    index1 = Map.get(Map.get(key, "location"), "i")
    index2 = Map.get(Map.get(key, "location"), "j")

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

    Map.update!(game, :arrayElements, fn (x) -> arrayElements end)
    |> Map.update!(:score, fn (x) -> x + 1 end)
    |> Map.update(:prev, key, fn (x) -> key end)
  end

  def nextState(game, key, false) do
    arrayElements = Map.get(game, :arrayElements)
    index1 = Map.get(Map.get(key, "location"), "i")
    index2 = Map.get(Map.get(key, "location"), "j")
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

    Map.update!(game, :arrayElements, fn (x) -> arrayElements end)
    |> Map.update!(:score, fn (x) -> x + 1 end)
    |> Map.update!(:prev, fn (x) -> false end)
  end
end