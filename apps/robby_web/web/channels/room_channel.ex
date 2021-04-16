defmodule RobbyWeb.RoomChannel do
  use RobbyWeb.Web, :channel
  require Ecto.Query

  alias RobbyWeb.{Repo, LdapRepo, Profile, Room, Message}

  def join("rooms:" <> room_id, payload, socket) do
    if authorized?(payload) do
      send(self(), {:after_join, payload})
      {:ok, assign(socket, :room_id, room_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info({:after_join, params}, socket) do
    room = Repo.get(Room, socket.assigns.room_id)
    messages = Repo.all(
      from m in assoc(room, :messages),
      preload: [:user],
      order_by: [desc: m.inserted_at],
      where: m.id > ^params["last_message_id"],
      limit: 100
    )
    emails =
      messages
      |> Enum.map(fn m -> m.user.username end)
      |> Enum.uniq
    users =
      Ecto.Query.from(u in Profile, where: u.mail in ^emails, select: {u.dn, u.cn})
      |> LdapRepo.all
      |> Enum.into(Map.new)

    processed_messages =
      messages
      |> Enum.map( fn m -> %{body: m.body, user: users[m.user.dn], inserted_at: m.inserted_at} end)

    push socket, "messages", %{messages: processed_messages}
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (rooms:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end


  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                                                                           #
  # TODO: Refactor this section.                                              #
  #       Ecto.Model.build has been fully deprecated, need to replace the     #
  #       call with the new Schema-based equivalen.                           #
  #                                                                           #
  #       At the moment, it appears as though this will produce an            #
  #       application failure.                                                #
  #                                                                           #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  def handle_in("new_msg", params = %{"body" => body}, socket) do
    Room
    |> Repo.get(socket.assigns.room_id)
    |> Ecto.Model.build(:messages)
    |> Message.changeset(Map.merge(params, %{"user_id" => socket.assigns.user.id, "body" => (body |> Phoenix.HTML.html_escape |> Phoenix.HTML.safe_to_string )}))
    |> Repo.insert!
    broadcast_from! socket, "new_msg", %{body: body, user: socket.assigns.ldap_user.cn}
    {:noreply, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
