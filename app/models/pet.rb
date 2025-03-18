class Pet < ApplicationRecord
  acts_as_votable

  belongs_to :user

  has_many_attached :photos

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

  ### CONSTANTS FOR SELECT OPTIONS ###

  SPECIES_OPTIONS = %w[dog cat].freeze
  BREED_OPTIONS = {
    'dog' => %w[Labrador Golden_Retriever Bulldog Poodle Other Don't_Know],
    'cat' => %w[Persian Siamese Maine_Coon Bengal Other Don't_Know]
  }.freeze
  GENDER_OPTIONS = %w[male female unknown].freeze
  SIZE_OPTIONS = %w[small medium large].freeze
  AGE_GROUP_OPTIONS = %w[puppy kitten adult senior].freeze
  TEMPERAMENT_OPTIONS = %w[calm energetic protective playful shy friendly].freeze
  PERSONALITY_TRAITS_OPTIONS = %w[affectionate independent curious social intelligent loyal playful active gentle].freeze
  LOOKING_FOR_OPTIONS = %w[socialize breeding].freeze
  PREFERRED_SPECIES_OPTIONS = %w[dog cat anything].freeze
  STATUS_OPTIONS = %w[available adopted looking inactive].freeze

  ### VALIDATIONS ###

  ## Basic Info (Text Inputs)
  validates :name, presence: true, length: { maximum: 50 }
  validates :bio, length: { maximum: 500 }, allow_blank: true

  ## Selection Fields (Dropdowns/Badges)
  validates :species, presence: true, inclusion: { in: SPECIES_OPTIONS }
  validates :breed, presence: true, length: { maximum: 50 }
  validates :gender, presence: true, inclusion: { in: GENDER_OPTIONS }
  validates :size, presence: true, inclusion: { in: SIZE_OPTIONS }
  validates :age_group, presence: true, inclusion: { in: AGE_GROUP_OPTIONS }
  validates :temperament, presence: true, inclusion: { in: TEMPERAMENT_OPTIONS }

  ## Multi-Select Fields (Badges)
  validates :personality_traits, length: { maximum: 4, message: 'You can select up to 4 traits' }, inclusion: { in: PERSONALITY_TRAITS_OPTIONS }, allow_blank: true
  validates :looking_for, length: { is: 1, message: 'You must choose either Socialize or Breeding' }, inclusion: { in: LOOKING_FOR_OPTIONS }
  validates :preferred_species, length: { is: 1, message: 'Choose one preferred species' }, inclusion: { in: PREFERRED_SPECIES_OPTIONS }

  ## Boolean Fields (Yes/No Toggles)
  validates :is_vaccinated, :is_neutered, :is_available_for_breeding, :registered_pedigree, inclusion: { in: [true, false] }

  ## Status Field
  validates :status, inclusion: { in: STATUS_OPTIONS }, allow_nil: true
end
