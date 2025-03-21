class LocationsController < ApplicationController
  before_action :authenticate_user!

  def nearby
    @location = Location.includes(user: :pets).where.not(user: { pets: { id: nil } }) # Only locations with pets
    @user_marker = { marker_html: render_to_string(partial: 'marker', locals: { pet: current_user.pets.first }) }
    @markers = @location.geocoded.map do |location|
      {
        lat: location.latitude,
        lng: location.longitude,
        marker_html: render_to_string(partial: 'marker', locals: { pet: location.user.pets.first })
      }
    end
  end
end
