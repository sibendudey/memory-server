defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel
  alias Memory.Game

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = Game.new()
      socket = socket
               |> assign(:game, game)
               |> assign(:name, name)
      {:ok, %{"join" => name, "game" => game}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end
  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("guess", %{ "clicked" => guess , "prev" => setPrevValue?}, socket) do
    map = socket.assigns[:game]
    game = Game.nextState(map, guess, setPrevValue?)
    IO.inspect game
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => game}}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (games:lobby).
#  def handle_in("shout", payload, socket) do
#    broadcast socket, "shout", payload
#    {:noreply, socket}
#  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end