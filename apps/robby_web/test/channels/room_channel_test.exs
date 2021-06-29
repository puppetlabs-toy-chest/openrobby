defmodule RobbyWeb.RoomChannelTest do
  use RobbyWeb.ChannelCase

  alias RobbyWeb.RoomChannel

  setup do
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(RoomChannel, "rooms:1")

    {:ok, socket: socket}
  end
end
