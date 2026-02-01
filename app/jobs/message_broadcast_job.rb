# frozen_string_literal: true

class MessageBroadcastJob < ApplicationJob
  queue_as :default

  # We pass message id to avoid serialization issues and keep the payload small.
  def perform(message_or_id)
    message =
      case message_or_id
      when Message then message_or_id
      else Message.find_by(id: message_or_id)
      end

    return unless message

    conversation = message.conversation
    return unless conversation

    # Broadcast the rendered HTML for the message so the client can append it.
    html = ApplicationController.render(
      partial: "messages/message",
      formats: [:html],
      locals: { message: message }
    )

    payload = {
      conversation_id: conversation.id,
      message_id: message.id,
      sender_id: message.sender_id,
      recipient_id: message.recipient_id,
      html: html,
      created_at: message.created_at&.iso8601
    }

    # Send to both participants (each user has their own stream)
    conversation.participants.find_each do |user|
      ActionCable.server.broadcast("messages:user:#{user.id}", payload)
    end
  rescue => e
    Rails.logger.error("[MessageBroadcastJob] #{e.class}: #{e.message}")
  end
end
