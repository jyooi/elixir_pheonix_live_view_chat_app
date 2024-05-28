defmodule ChatAppWeb.ChatRoomLive do
  use ChatAppWeb, :live_view
  alias ChatApp.Chat
  import Timex

  def mount(params, _session, socket) do
    timezone = Map.get(params, "timezone", "Etc/UTC")
    if connected?(socket), do: Phoenix.PubSub.subscribe(ChatApp.PubSub, "chat_room")
    messages = Chat.list_messages()

    {:ok,
     assign(socket,
       messages: messages,
       username: "",
       user_joined: false,
       message: "",
       timezone: timezone
     )}
  end

  def handle_event("set_username", %{"username" => username}, socket) do
    {:noreply, assign(socket, username: username, user_joined: true)}
  end

  def handle_event("update_message", %{"message" => message}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  def handle_event("send_message", %{"message" => "/clear"}, socket) do
    Chat.clear_messages()
    Phoenix.PubSub.broadcast(ChatApp.PubSub, "chat_room", :clear_messages)
    {:noreply, assign(socket, messages: [])}
  end

  def handle_event("send_message", %{"message" => message}, socket) do
    new_message = %{user: socket.assigns.username, body: message}

    case Chat.create_message(new_message) do
      {:ok, message} ->
        Phoenix.PubSub.broadcast(ChatApp.PubSub, "chat_room", {:new_message, message})
        # Clear the input field
        {:noreply, assign(socket, message: "")}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("clear_messages", _params, socket) do
    Chat.clear_messages()
    Phoenix.PubSub.broadcast(ChatApp.PubSub, "chat_room", :clear_messages)
    {:noreply, assign(socket, messages: [])}
  end

  def handle_info(:clear_messages, socket) do
    {:noreply, assign(socket, messages: [])}
  end

  def handle_info({:new_message, message}, socket) do
    {:noreply, update(socket, :messages, fn messages -> [message | messages] end)}
  end

  def convert_to_local_time(datetime, timezone) do
    datetime
    |> Timex.to_datetime("Etc/UTC")
    |> Timex.Timezone.convert(timezone)
    |> Timex.format!("{Mshort} {D}, {YYYY} {h12}:{m} {AM}")
  end
end
