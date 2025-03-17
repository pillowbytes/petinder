class PetsController < ApplicationController
  before_action :set_pet, only: %i[show edit update destroy]

  def index
    @pets = Pet.all
  end

  def show
  end

  def new
    @pet = Pet.new
  end

  def edit
  end

  def create
    @pet = current_user.pets.build(pet_params)

    Rails.logger.debug "Filtered Params: #{pet_params.inspect}"
    Rails.logger.debug "Final Pet Status Before Save: #{@pet.status.inspect}" # Debugging

    if @pet.save
      redirect_to @pet, notice: 'Amiguinho criado.'
    else
      Rails.logger.debug "Pet save failed: #{@pet.errors.full_messages}" # Debugging
      render :new, status: :unprocessable_entity
    end
  end
  def update
    if @pet.update(pet_params)
      redirect_to @pet, notice: 'Amiguinho atualizado.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pet.destroy
    redirect_to pets_url, notice: 'Amiguinho deletato :(', status: :see_other
  end

  private

  def pet_params
    permitted_params = params.require(:pet).permit(
      :name,
      :species,
      :breed,
      :age_group,
      :size,
      :gender,
      :temperament,
      :bio,
      :status,
      :is_vaccinated,
      :is_neutered,
      :is_available_for_breeding,
      :registered_pedigree,
      personality_traits: [],
      medical_conditions: [],
      looking_for: [],
      preferred_species: [],
      preferred_size: []
    )

    # Converting empty array values to nil to pass model validations
    %i[personality_traits looking_for preferred_species preferred_size].each do |field|
      permitted_params[field] = permitted_params[field].reject(&:blank?)
      permitted_params[field] = nil if permitted_params[field].empty? # Avoid sending empty arrays
    end

    # Converting "Yes"/"No" to true/false for boolean fields
    %i[is_vaccinated is_neutered is_available_for_breeding registered_pedigree].each do |field|
      permitted_params[field] = ActiveModel::Type::Boolean.new.cast(permitted_params[field])
    end

    permitted_params
  end

  def set_pet
    @pet = current_user.pets.find(params[:id])
  end
end
