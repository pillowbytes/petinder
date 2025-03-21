class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_current_pet
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    added_attrs = [:first_name, :last_name, :street, :city, :state, :zip_code, :country]
    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
    devise_parameter_sanitizer.permit(:account_update, keys: added_attrs)
  end

  private

  def set_current_pet
    if session[:current_pet_id]
      @current_pet = current_user.pets.find_by(id: session[:current_pet_id])
    end
  end

  def require_pet_selection
    if @current_pet.nil?
      if current_user.pets.any?
        # flash[:alert] = "Please select a pet to continue."
        redirect_to select_pet_path
      else
        # flash[:alert] = "You need to create a pet before proceeding."
        redirect_to new_pet_path
      end
    end
  end
end

  # include Pundit::Authorization

  # # Pundit: allow-list approach
  # after_action :verify_authorized, except: :index, unless: :skip_pundit?
  # after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # # Uncomment when you *really understand* Pundit!
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # def user_not_authorized
  #   flash[:alert] = 'Gabi said: You are not authorized to perform this action.'
  #   redirect_to(root_path)
  # end

  # private

  # def skip_pundit?
  #   devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  # end
