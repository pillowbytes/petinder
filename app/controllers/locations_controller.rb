class LocationsController < ApplicationController
  before_action :authenticate_user!

  # def nearby
  #   @current_pet = Pet.find_by(id: session[:current_pet_id])
  #   @location = Location.includes(user: :pets).where.not(user: { pets: { id: nil } }) # Only locations with pets
  #   @user_marker = { marker_html: render_to_string(partial: 'marker', locals: { pet: @current_pet }) }
  #   @markers = @location.geocoded.map do |location|
  #     {
  #       lat: location.latitude,
  #       lng: location.longitude,
  #       marker_html: render_to_string(partial: 'marker', locals: { pet: location.user.pets.first })
  #     }
  #   end
  # end

  def nearby
    @current_pet = Pet.find_by(id: session[:current_pet_id])
    @location = Location.includes(user: :pets).where.not(user: { pets: { id: nil } })

    @geojson_markers = @location.geocoded.map do |location|
      pet = location.user.pets.first
      next unless pet

      {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [location.longitude, location.latitude]
        },
        properties: {
          name: pet.name,
          photo_url: pet.photos.attached? ? cl_image_path(pet.photos.first.key, width: 80, height: 80, crop: "fill") : view_context.image_path("pet_placeholder.webp"),
          is_current_user: pet.id == @current_pet&.id
        }
      }
    end.compact

    @geojson_markers = {
      type: 'FeatureCollection',
      features: @geojson_markers
    }
  end


end
