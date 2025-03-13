class Match < ApplicationRecord
  belongs_to :pet
  belongs_to :matched_pet, class_name: 'Pet'

  validates :status, presence: true
end
