class Message < ApplicationRecord
  # Associations
  belongs_to :conversation
  belongs_to :sender, class_name: 'User'

  # Validations
  validates :content, presence: true

  # Callbacks
  after_create :update_conversation_timestamp

  private

  def update_conversation_timestamp
    conversation.update(last_message_at: created_at)
  end
end

