class Conversation < ApplicationRecord
  # Associations
  belongs_to :initiator, class_name: 'User'
  belongs_to :assigned_expert, class_name: 'User', optional: true
  has_many :messages, dependent: :destroy
  has_many :expert_assignments, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: %w[waiting active resolved] }

  # Scopes
  scope :waiting, -> { where(status: 'waiting') }
  scope :active, -> { where(status: 'active') }
  scope :for_user, ->(user_id) { where('initiator_id = ? OR assigned_expert_id = ?', user_id, user_id) }

  # Get unread message count for a specific user
  def unread_count_for(user)
    messages.where(is_read: false).where.not(sender_id: user.id).count
  end

  # Get the role of a user in this conversation
  def role_for(user)
    if initiator_id == user.id
      'initiator'
    elsif assigned_expert_id == user.id
      'expert'
    else
      nil
    end
  end
end

