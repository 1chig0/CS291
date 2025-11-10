class MessagesController < ApplicationController
  include JwtAuthentication

  def index
    conversation = Conversation.for_user(current_user.id).find_by(id: params[:conversation_id])

    unless conversation
      render json: { error: 'Conversation not found' }, status: :not_found
      return
    end

    messages = conversation.messages.order(created_at: :asc)
    render json: messages.map { |m| message_response(m, conversation) }, status: :ok
  end

  def create
    conversation = Conversation.for_user(current_user.id).find_by(id: params[:conversationId])

    unless conversation
      render json: { error: 'Conversation not found' }, status: :not_found
      return
    end

    message = conversation.messages.new(
      sender: current_user,
      content: params[:content],
      is_read: false
    )

    if message.save
      render json: message_response(message, conversation), status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def read
    message = Message.find_by(id: params[:id])

    unless message
      render json: { error: 'Message not found' }, status: :not_found
      return
    end

    # Can't mark your own messages as read
    if message.sender_id == current_user.id
      render json: { error: 'Cannot mark your own messages as read' }, status: :forbidden
      return
    end

    message.update(is_read: true)
    render json: { success: true }, status: :ok
  end

  private

  def message_response(message, conversation)
    {
      id: message.id.to_s,
      conversationId: message.conversation_id.to_s,
      senderId: message.sender_id.to_s,
      senderUsername: message.sender.username,
      senderRole: conversation.role_for(message.sender),
      content: message.content,
      timestamp: message.created_at.iso8601,
      isRead: message.is_read
    }
  end
end

