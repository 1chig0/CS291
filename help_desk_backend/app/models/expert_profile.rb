class ExpertProfile < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :user_id, uniqueness: true

  # Set default value for JSON column
  attribute :knowledge_base_links, :json, default: []

  # Ensure we always return an array
  def knowledge_base_links
    read_attribute(:knowledge_base_links) || []
  end
end

