module Expert
  class ExpertController < ApplicationController
    include JwtAuthentication

    def queue
      waiting_conversations = Conversation.waiting.order(created_at: :asc)
      assigned_conversations = Conversation.where(assigned_expert_id: current_user.id, status: 'active')
                                            .order(updated_at: :desc)

      render json: {
        waitingConversations: waiting_conversations.map { |c| conversation_response(c) },
        assignedConversations: assigned_conversations.map { |c| conversation_response(c) }
      }, status: :ok
    end

    def claim
      conversation = Conversation.find_by(id: params[:conversation_id])

      unless conversation
        render json: { error: 'Conversation not found' }, status: :not_found
        return
      end

      if conversation.assigned_expert_id.present?
        render json: { error: 'Conversation is already assigned to an expert' }, status: :unprocessable_entity
        return
      end

      conversation.update!(
        assigned_expert_id: current_user.id,
        status: 'active'
      )

      # Create expert assignment record
      ExpertAssignment.create!(
        conversation: conversation,
        expert: current_user,
        status: 'active',
        assigned_at: Time.current
      )

      render json: { success: true }, status: :ok
    end

    def unclaim
      conversation = Conversation.find_by(id: params[:conversation_id])

      unless conversation
        render json: { error: 'Conversation not found' }, status: :not_found
        return
      end

      if conversation.assigned_expert_id != current_user.id
        render json: { error: 'You are not assigned to this conversation' }, status: :forbidden
        return
      end

      # Update assignment to unassigned
      assignment = conversation.expert_assignments.active.find_by(expert_id: current_user.id)
      assignment&.update(status: 'unassigned')

      conversation.update!(
        assigned_expert_id: nil,
        status: 'waiting'
      )

      render json: { success: true }, status: :ok
    end

    def profile
      expert_profile = current_user.expert_profile

      unless expert_profile
        render json: { error: 'Expert profile not found' }, status: :not_found
        return
      end

      render json: expert_profile_response(expert_profile), status: :ok
    end

    def update_profile
      expert_profile = current_user.expert_profile

      unless expert_profile
        render json: { error: 'Expert profile not found' }, status: :not_found
        return
      end

      # Transform camelCase to snake_case for Rails
      update_params = {
        bio: params[:bio],
        knowledge_base_links: params[:knowledgeBaseLinks] || params[:knowledge_base_links]
      }

      if expert_profile.update(update_params)
        render json: expert_profile_response(expert_profile), status: :ok
      else
        render json: { errors: expert_profile.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def assignments_history
      assignments = current_user.expert_assignments.order(assigned_at: :desc)

      render json: assignments.map { |a| assignment_response(a) }, status: :ok
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

    def expert_profile_response(profile)
      {
        id: profile.id.to_s,
        userId: profile.user_id.to_s,
        bio: profile.bio,
        knowledgeBaseLinks: profile.knowledge_base_links,
        createdAt: profile.created_at.iso8601,
        updatedAt: profile.updated_at.iso8601
      }
    end

    def assignment_response(assignment)
      {
        id: assignment.id.to_s,
        conversationId: assignment.conversation_id.to_s,
        expertId: assignment.expert_id.to_s,
        status: assignment.status,
        assignedAt: assignment.assigned_at.iso8601,
        resolvedAt: assignment.resolved_at&.iso8601,
        rating: assignment.rating
      }
    end

    def expert_profile_params
      params.permit(:bio, knowledge_base_links: [])
    end
  end
end

