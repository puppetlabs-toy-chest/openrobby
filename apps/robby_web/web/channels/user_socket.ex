defmodule RobbyWeb.UserSocket do
  use Phoenix.Socket
  alias RobbyWeb.{User, Directory, Repo, LdapRepo}

  ## Channels
  channel "search:*", RobbyWeb.SearchChannel
  channel "rooms:*", RobbyWeb.RoomChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"token" => token}, socket) do
    with {:ok, %{user_id: id}} <- Phoenix.Token.verify(RobbyWeb.Endpoint, "user_token_salt", token) do
      user = Repo.get(User, id)
      ldap_user = LdapRepo.get(Directory, user.dn)
      new_socket =
        socket
        |> assign(:user_id, id)
        |> assign(:user, user)
        |> assign(:ldap_user, ldap_user)
      {:ok, new_socket}
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     RobbyWeb.Endpoint.broadcast("users_socket:" <> user.id, "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
