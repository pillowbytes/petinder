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

  SPECIES_OPTIONS = ["Cachorro", "Gato"].freeze
  BREED_OPTIONS = {
    "Cachorro" => ["Labrador", "Golden Retriever", "Bulldog", "Poodle", "Outro"],
    "Gato" => ["Persa", "Siamês", "Maine Coon", "Bengal", "Outro"]
  }.freeze
  GENDER_OPTIONS = ["Macho", "Fêmea", "Desconhecido"].freeze
  SIZE_OPTIONS = ["Pequeno", "Médio", "Grande"].freeze
  AGE_GROUP_OPTIONS = ["Filhote", "Adulto", "Sênior"].freeze
  TEMPERAMENT_OPTIONS = ["Calmo", "Energético", "Protetor", "Brincalhão", "Tímido", "Amigável"].freeze
  PERSONALITY_TRAITS_OPTIONS = ["Afetuoso", "Independente", "Curioso", "Sociável", "Inteligente", "Leal", "Brincalhão", "Ativo", "Gentil"].freeze
  LOOKING_FOR_OPTIONS = ["Socializar", "Reprodução"].freeze
  PREFERRED_SPECIES_OPTIONS = ["Cachorro", "Gato", "Qualquer"].freeze
  STATUS_OPTIONS = ["Disponível", "Adotado", "Procurando", "Inativo"].freeze

  ### VALIDAÇÕES ###

  ## Informações Básicas (Campos de Texto)
  validates :name, presence: true, length: { maximum: 50 }
  validates :bio, length: { maximum: 500 }, allow_blank: true
  validates :age, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 25 }

  ## Campos de Seleção (Dropdowns/Badges)
  validates :species, presence: true, inclusion: { in: SPECIES_OPTIONS }
  validates :breed, presence: true, length: { maximum: 50 }
  validates :gender, presence: true, inclusion: { in: GENDER_OPTIONS }
  validates :size, presence: true, inclusion: { in: SIZE_OPTIONS }
  validates :age_group, presence: true, inclusion: { in: AGE_GROUP_OPTIONS }
  validates :temperament, presence: true, inclusion: { in: TEMPERAMENT_OPTIONS }

  ## Campos de Múltipla Seleção (Badges)
  validates :personality_traits, length: { maximum: 4, message: "Você pode selecionar até 4 traços" }, inclusion: { in: PERSONALITY_TRAITS_OPTIONS }, allow_blank: true
  validates :looking_for, length: { is: 1, message: "Você deve escolher entre Socializar ou Reprodução" }, inclusion: { in: LOOKING_FOR_OPTIONS }
  validates :preferred_species, length: { is: 1, message: "Escolha uma espécie preferida" }, inclusion: { in: PREFERRED_SPECIES_OPTIONS }

  ## Campos Booleanos (Alternância Sim/Não)
  validates :is_vaccinated, :is_neutered, :is_available_for_breeding, :registered_pedigree, inclusion: { in: [true, false] }

  ## Campo de Status
  validates :status, inclusion: { in: STATUS_OPTIONS }, allow_nil: true
end
