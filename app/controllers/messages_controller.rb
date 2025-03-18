class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @match = Match.find(params[:match_id])
    @message = @match.messages.build(message_params)
    @message.pet = @match.pet.user == current_user ? @match.pet : @match.matched_pet

    if @message.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(:messages, partial: "messages/message",
            locals: { message: @message, pet: @message.pet })
        end
        format.html { redirect_to match_path(@match) }
      end
    else
      render 'matches/show', status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :pet_id)
  end
end
