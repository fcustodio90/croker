class Portfolio < ApplicationRecord
  belongs_to :user
  belongs_to :cryptocurrency

  validates :amount_held, numericality: { greater_than_or_equal_to: 0 }, presence: true
end