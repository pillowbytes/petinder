class LocationsController < ApplicationController
  before_action :authenticate_user!

  def current
  end
end
