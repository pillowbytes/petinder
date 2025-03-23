class LocationsController < ApplicationController
  before_action :authenticate_user!

  def nearby
    @current_pet = Pet.find_by(id: session[:current_pet_id])
    @location = Location.includes(user: :pets).where.not(user: { pets: { id: nil } }) # Only locations with pets
    @user_marker = { marker_html: render_to_string(partial: 'marker', locals: { pet: @current_pet }) }

    @markers = @location.geocoded.map do |location|
      {
        lat: location.latitude,
        lng: location.longitude,
        marker_html: render_to_string(partial: 'marker', locals: { pet: location.user.pets.first }),
        name: location.user.pets.first.name,
        last_seen: "#{rand(1..30)} min ago"
      }
    end
  end
end
