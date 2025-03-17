class LocationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_location, only: [:show]

  def show
    @location = current_user.location
    redirect_to root_path, alert: "Location not found" unless @location
  end

  private

  def set_location
    @location = current_user.location
    # Basic authorization to prevent users from seeing others' locations
    # redirect_to root_path, alert: "Not authorized" unless @location.user == current_user
  end
end
