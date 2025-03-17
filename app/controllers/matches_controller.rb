class MatchesController < ApplicationController
  before_action :authenticate_user!

  def show
    @match = Match.find(params[:id])
  end
end
