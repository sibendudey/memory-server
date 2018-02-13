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
      :clickable => true,
      :next => false,
      :prev => false
    }
  end

  def nextState(game, key, true) do
    arrayElements = nextState(Map.get(game, :arrayElements), key)

    currElement = Enum.at(
      Enum.at(
        arrayElements,
        Enum.at(key, 0)
        |> Map.get("i")
      ),
      Enum.at(key, 0)
      |> Map.get("j")
    )

    location = arrayElements
               |> Enum.with_index
               |> Enum.filter(
                    fn {x, i} ->
                      Enum.any?(x, fn (x) -> x.value == currElement.value && !x.display end)
                    end
                  )
               |> Enum.at(0)
               |> Tuple.to_list

    locationMap = %{
      i: Enum.at(location, 1),
      j: Enum.at(location, 0)
         |> Enum.with_index
         |> Enum.filter(fn {x, j} -> (x.value == currElement.value && !x.display) end)
         |> Enum.at(0)
         |> Kernel.elem(1)
    }

    Map.update!(game, :arrayElements, fn (x) -> arrayElements end)
    |> Map.update!(
         :score,
         fn (x) ->
             x + 1
         end
       )
    |> Map.update(:next, key, fn (x) -> locationMap end)
    |> Map.update(:prev, key, fn (x) -> Enum.at(key, 0) end)
  end

  def client_view(game) do
    %{
      score: game.score,
      arrayElements: filter(game.arrayElements),
      clickable: true,
      next: game.next,
      prev: game.prev
    }
  end

  def filter(arrayElements) do
    Enum.map(
      arrayElements,
      fn (ele) ->
        Enum.map(
          ele,
          fn (x) -> if (!x.display) do
                      %{value: " ", display: x.display}
                    else
                      x
                    end
          end
        )
      end
    )
  end

  def nextState(game, key, false) do
    arrayElements = nextState(Map.get(game, :arrayElements), key)
    Map.update!(game, :arrayElements, fn (x) -> arrayElements end)
    |> Map.update!(:score, fn (x) -> if (rem(x, 2) == 1) do
                                       x + 1
                                     else
                                       x
                                     end end)
    |> Map.update!(:next, fn (x) -> false end)
    |> Map.update!(:prev, fn (x) -> false end)
  end

  def nextState(arrayElements, key) do
    List.foldl(
      key,
      arrayElements,
      fn (l, al) ->
        index1 = Map.get(l, "i")
        index2 = Map.get(l, "j")
        al
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
      end
    )
  end

end



