module Api
  class UpdatesController < ApplicationController
    include JwtAuthentication

    def conversations
      user_id = params[:userId]
      since = params[:since] ? Time.zone.parse(params[:since]) : 1.year.ago

      conversations = Conversation.for_user(user_id)
                                   .where('updated_at > ?', since)
                                   .order(updated_at: :desc)

      render json: conversations.map { |c| conversation_response(c) }, status: :ok
    end

    def messages
      user_id = params[:userId]
      since = params[:since] ? Time.zone.parse(params[:since]) : 1.year.ago

      # Get conversations for this user
      conversation_ids = Conversation.for_user(user_id).pluck(:id)

      # Get messages in those conversations created after 'since'
      messages = Message.where(conversation_id: conversation_ids)
                        .where('created_at > ?', since)
                        .order(created_at: :asc)

      render json: messages.map { |m| message_response(m) }, status: :ok
    end

    def expert_queue
      expert_id = params[:expertId]
      since = params[:since] ? Time.zone.parse(params[:since]) : 1.year.ago

      # Get waiting conversations updated after 'since'
      waiting_conversations = Conversation.waiting
                                          .where('updated_at > ?', since)
                                          .order(created_at: :asc)

      # Get conversations assigned to this expert updated after 'since'
      assigned_conversations = Conversation.where(assigned_expert_id: expert_id, status: 'active')
                                           .where('updated_at > ?', since)
                                           .order(updated_at: :desc)

      result = {
        waitingConversations: waiting_conversations.map { |c| conversation_response(c) },
        assignedConversations: assigned_conversations.map { |c| conversation_response(c) }
      }

      render json: [result], status: :ok
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

    def message_response(message)
      conversation = message.conversation
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
end

