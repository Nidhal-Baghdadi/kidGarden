# frozen_string_literal: true

class MessagesChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user
    stream_from "messages:user:#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
