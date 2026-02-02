import consumer from "channels/consumer"

consumer.subscriptions.create("MessagesChannel", {
  received(data) {
    const container = document.getElementById("messages-container")
    if (!container) return

    const currentConversationIdEl = document.querySelector("[data-conversation-id]")
    const currentConversationId = currentConversationIdEl?.dataset?.conversationId
    if (currentConversationId && String(data.conversation_id) !== String(currentConversationId)) return

    // Get current user ID from meta tag
    const currentUserMeta = document.querySelector('meta[name="current-user-id"]');
    const currentUserId = currentUserMeta ? currentUserMeta.getAttribute('content') : null;

    if (currentUserId) {
      // Create a temporary element to parse the HTML
      const tempDiv = document.createElement('div');
      tempDiv.innerHTML = data.html.trim();

      const wrapperElement = tempDiv.firstElementChild;
      if (wrapperElement) {
        const senderId = wrapperElement.getAttribute('data-sender-id');
        const isMine = senderId === currentUserId.toString();

        // Extract content and time from the wrapper
        const contentDiv = wrapperElement.querySelector('.msg__content');
        const timeSpan = wrapperElement.querySelector('.msg__time');

        // Create the proper message bubble structure
        const messageBubble = document.createElement('div');
        messageBubble.className = isMine ? 'message-bubble message-bubble--mine' : 'message-bubble message-bubble--theirs';

        // Create content div with proper class
        const contentWrapper = document.createElement('div');
        contentWrapper.className = 'message-bubble__content';
        if (contentDiv) {
          contentWrapper.innerHTML = contentDiv.innerHTML;
        }

        // Create meta div with proper class
        const metaDiv = document.createElement('div');
        metaDiv.className = 'message-bubble__meta';
        if (timeSpan) {
          metaDiv.textContent = timeSpan.textContent;
        }
        if (isMine) {
          const statusSpan = document.createElement('span');
          statusSpan.title = "Status";
          statusSpan.textContent = "• Sent";
          metaDiv.appendChild(statusSpan);
        }

        // Assemble the message bubble
        messageBubble.appendChild(contentWrapper);
        messageBubble.appendChild(metaDiv);

        // Insert the properly formatted message
        container.insertAdjacentHTML("beforeend", messageBubble.outerHTML);
      } else {
        // Fallback if parsing fails
        container.insertAdjacentHTML("beforeend", data.html);
      }
    } else {
      // Fallback to original behavior if current user ID is not available
      container.insertAdjacentHTML("beforeend", data.html)
    }

    container.scrollTop = container.scrollHeight
  }
})
