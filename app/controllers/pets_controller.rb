class PetsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_pet_selection, only: [:swipe]
  before_action :set_pet, only: %i[show edit update destroy]

  def index
    @pets = current_user.pets
  end

  def show
  end

  def new
    @pet = Pet.new
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

  def edit
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

  # def swipe
  #   @pet = Pet.find(params[:id])
  #   # @matches = @pet.matches.where(user: current_user)
  #   @matches = Match.where(pet: @pet).or(Match.where(matched_pet: @pet))

  #   # Find all pets that this pet has already swiped on (liked)
  #   swiped_pet_ids = @pet.find_votes_for(vote_scope: nil).pluck(:votable_id)

  #   # Exclude already swiped pets and user's own pets
  #   @potential_pets = Pet.where.not(id: swiped_pet_ids)
  #                        .where.not(user: current_user)
  # end

  # def process_swipe
  #   @pet = Pet.find(params[:id])
  #   liked_pet = Pet.find(params[:liked_pet_id])

  #   # Register the like
  #   @pet.liked_by(liked_pet)

  #   # Check for mutual like
  #   if liked_pet.voted_up_by?(@pet)
  #     match = create_match(@pet, liked_pet)
  #     redirect_to match_path(match)
  #   # else
  #   #   flash[:notice] = '🎉 Match registered!'
  #   end

  def swipe
    @pet = @current_pet
    @matches = Match.where(pet: @pet).or(Match.where(matched_pet: @pet))

    # Find all pets that this pet has already swiped on
    swiped_pet_ids = @pet.find_votes_for(vote_scope: nil).pluck(:votable_id)

    # Exclude already swiped pets and user's own pets
    @potential_pets = Pet.where.not(id: swiped_pet_ids)
                         .where.not(user: current_user)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def process_swipe
    @pet = @current_pet
    liked_pet = Pet.find(params[:pet][:liked_pet_id])
    swipe_action = params[:pet][:swipe_action]

    match = right_swipe(@pet, liked_pet) if swipe_action == 'right'

    respond_to do |format|
      format.turbo_stream do
        if match
          render turbo_stream: turbo_stream.replace(
            'pet_card',
            partial: 'matches/matched',
            locals: { match: match }
          )
        else
          # Store swiped pets in session
          session[:swiped_pet_ids] ||= []
          session[:swiped_pet_ids] << liked_pet.id unless session[:swiped_pet_ids].include?(liked_pet.id)

          @potential_pets = Pet.where.not(id: session[:swiped_pet_ids])
                               .where.not(user: current_user)
                               .order(:id)

          if @potential_pets.any?
            next_pet = @potential_pets.first
            render turbo_stream: turbo_stream.replace(
              'pet_card',
              partial: 'pets/swipe_pet',
              locals: { current_pet: @pet, potential_pet: next_pet }
            )
          else
            render turbo_stream: turbo_stream.replace(
              'pet_card',
              partial: 'pets/no-pets'
            )
          end
        end
      end
    end
  end

  def select
    @pets = current_user.pets
    @redirect_path = params[:redirect_to] || root_path
  end

  def set_selected_pet
    pet = current_user.pets.find_by(id: params[:pet_id])
    if pet
      session[:current_pet_id] = pet.id
      redirect_to swipe_pet_path(pet), notice: "Pet selected!"
    else
      redirect_to select_pet_path, alert: "Invalid pet selection."
    end
  end

  def dev_tests
    @pets = Pet.includes(:user, :initiated_matches, :received_matches).all
  end

  private

  def create_match(pet1, pet2)
    Match.create!(pet: pet1, matched_pet: pet2, status: 'matched')
  end

  def pet_params
    permitted_params = params.require(:pet).permit(
      :name,
      :species,
      :breed,
      :age_group,
      :age,
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
      preferred_size: [],
      photos: []
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

  def right_swipe(current_pet, liked_pet)
    # Registering Like
    current_pet.liked_by(liked_pet)

    # Check for mutual like
    if liked_pet.voted_up_by?(current_pet)
      match = create_match(current_pet, liked_pet)
      return match
    end

    nil # Return nil if no match
  end
end
