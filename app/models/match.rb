class Match < ApplicationRecord
  belongs_to :pet
  belongs_to :matched_pet, class_name: 'Pet'
  has_many :messages, dependent: :destroy

  validates :status, presence: true
end
