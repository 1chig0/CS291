class ConversationsController < ApplicationController
  include JwtAuthentication

  def index
    conversations = Conversation.for_user(current_user.id)
                                 .order(updated_at: :desc)

    render json: conversations.map { |c| conversation_response(c) }, status: :ok
  end

  def show
    conversation = Conversation.for_user(current_user.id).find_by(id: params[:id])

    if conversation
      render json: conversation_response(conversation), status: :ok
    else
      render json: { error: 'Conversation not found' }, status: :not_found
    end
  end

  def create
    conversation = Conversation.new(
      title: params[:title],
      initiator: current_user,
      status: 'waiting'
    )

    if conversation.save
      render json: conversation_response(conversation), status: :created
    else
      render json: { errors: conversation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def conversation_response(conversation)
    {
      id: conversation.id.to_s,
      title: conversation.title,
      status: conversation.status,
      questionerId: conversation.initiator_id.to_s,
      questionerUsername: conversation.initiator.username,
      assignedExpertId: conversation.assigned_expert_id&.to_s,
      assignedExpertUsername: conversation.assigned_expert&.username,
      createdAt: conversation.created_at.iso8601,
      updatedAt: conversation.updated_at.iso8601,
      lastMessageAt: conversation.last_message_at&.iso8601,
      unreadCount: conversation.unread_count_for(current_user)
    }
  end
end

