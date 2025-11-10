class ExpertAssignment < ApplicationRecord
  # Associations
  belongs_to :conversation
  belongs_to :expert, class_name: 'User'

  # Validations
  validates :status, presence: true, inclusion: { in: %w[active resolved unassigned] }
  validates :assigned_at, presence: true

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :resolved, -> { where(status: 'resolved') }
end

