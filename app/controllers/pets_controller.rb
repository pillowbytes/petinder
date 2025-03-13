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

    if @pet.save
      redirect_to @pet, notice: 'Amiguinho criado.'
    else
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
    params.require(:pet).permit(
      :name,
      :species,
      :breed,
      :age,
      :gender,
      :bio,
      :personality_traits,
      :temperament,
      :size,
      :age_group,
      :is_vaccinated,
      :is_neutered,
      :medical_conditions,
      :is_available_for_breeding,
      :breeding_history,
      :registered_pedigree,
      :looking_for,
      :preferred_species,
      :preferred_size,
      :status
    )
  end

  def set_pet
    @pet = current_user.pets.find(params[:id])
  end
end
