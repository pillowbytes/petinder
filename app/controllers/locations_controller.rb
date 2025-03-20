class LocationsController < ApplicationController
  before_action :authenticate_user!

  def nearby
    @location = Location.all
    @markers = @location.geocoded.map do |location|
      {
        lat: location.latitude,
        lng: location.longitude
      }
    end
  end
end
