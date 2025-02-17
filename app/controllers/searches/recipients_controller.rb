class Searches::RecipientsController < ApplicationController
  def show
    @recipients = User.includes(:profile).where("profiles.name LIKE :query OR email_addresses.email LIKE :query", query: "%#{params[:q]}%").order("profiles.name ASC").map { |u| { id: u.id, text: u.profile&.name || u.email } }
    # render json: @recipients
  end
end
