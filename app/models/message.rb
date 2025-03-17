class Message < ApplicationRecord
  belongs_to :pet
  belongs_to :match
end
