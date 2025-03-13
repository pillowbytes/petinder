class Pet < ApplicationRecord
  belongs_to :user

  has_many :initiated_matches,
  class_name: 'Match',
  foreign_key: 'pet_id',
  dependent: :destroy

  has_many :matched_pets,
  through: :initiated_matches,
  source: :matched_pet

  has_many :received_matches,
  class_name: 'Match',
  foreign_key: 'matched_pet_id',
  dependent: :destroy

  has_many :pets_who_matched_me,
  through: :received_matches,
  source: :pet
end
