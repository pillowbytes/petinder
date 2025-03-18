class MatchesController < ApplicationController
  before_action :authenticate_user!

  # Getting all pets messages for now (future: impersonate(sudo) functionality)
  def index
    @matches = Match.where(pet: current_user.pets).or(Match.where(matched_pet: current_user.pets))
  end

  # We want pet specific messages `/pets/:id/matches`
  def pet_matches
    @pet = Pet.find(params[:pet_id])
    @matches = Match.where(pet: @pet).or(Match.where(matched_pet: @pet))
  end

  def show
    @match = Match.find(params[:id])
  end

  # For now this shows messages between two matched pets: `/pets/:id/matches/:id/messages`
  def messages
    @match = Match.find(params[:match_id])
    @messages = @match.messages.order(created_at: :asc)
    @message = Message.new
  end
end
