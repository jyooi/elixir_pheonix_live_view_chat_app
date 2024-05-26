defmodule ChatAppWeb.ChatRoomLive do
  use ChatAppWeb, :live_view
  alias ChatApp.Chat

  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(ChatApp.PubSub, "chat_room")
    messages = Chat.list_messages()
    {:ok, assign(socket, messages: messages, username: "", user_joined: false, message: "")}
  end

  def handle_event("set_username", %{"username" => username}, socket) do
    {:noreply, assign(socket, username: username, user_joined: true)}
  end

  def handle_event("update_message", %{"message" => message}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  def handle_event("send_message", _params, socket) do
    new_message = %{user: socket.assigns.username, body: socket.assigns.message}

    case Chat.create_message(new_message) do
      {:ok, message} ->
        Phoenix.PubSub.broadcast(ChatApp.PubSub, "chat_room", {:new_message, message})
        # Clear the input field
        {:noreply, assign(socket, message: "")}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_info({:new_message, message}, socket) do
    {:noreply, update(socket, :messages, fn messages -> [message | messages] end)}
  end
end
