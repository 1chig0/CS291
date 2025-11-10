class User < ApplicationRecord
  has_secure_password

  # Associations
  has_one :expert_profile, dependent: :destroy
  has_many :initiated_conversations, class_name: 'Conversation', foreign_key: 'initiator_id', dependent: :destroy
  has_many :assigned_conversations, class_name: 'Conversation', foreign_key: 'assigned_expert_id'
  has_many :messages, foreign_key: 'sender_id', dependent: :destroy
  has_many :expert_assignments, foreign_key: 'expert_id', dependent: :destroy

  # Validations
  validates :username, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { password.present? }

  # Callbacks
  after_create :create_expert_profile_for_user

  # Update last active timestamp
  def update_last_active!
    update(last_active_at: Time.current)
  end

  private

  def create_expert_profile_for_user
    ExpertProfile.create!(user: self)
  end
end

