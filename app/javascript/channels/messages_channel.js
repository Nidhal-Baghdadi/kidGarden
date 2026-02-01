import consumer from "./consumer"

consumer.subscriptions.create("MessagesChannel", {
  received(data) {
    const container = document.getElementById("messages-container")
    if (!container) return

    const currentConversationIdEl = document.querySelector("[data-conversation-id]")
    const currentConversationId = currentConversationIdEl?.dataset?.conversationId
    if (currentConversationId && String(data.conversation_id) !== String(currentConversationId)) return

    container.insertAdjacentHTML("beforeend", data.html)
    container.scrollTop = container.scrollHeight
  }
})
