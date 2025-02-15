class InventoryInvitationsController < ApplicationController
  before_action :set_inventory, except: [:accept, :decline]
  before_action :set_invitation, only: [:accept, :decline]

  def new
    @invitation = @inventory.inventory_invitations.new
  end

  def create
    @invitation = @inventory.inventory_invitations.new(invitation_params)
    @invitation.sender = Current.user
    
    if @invitation.save
      redirect_to inventory_inventory_users_path(@inventory),
        notice: "Invitation sent successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def accept
    authorize @invitation, :respond?
    @invitation.accepted!
    redirect_to inventory_path(@invitation.inventory), notice: "You have joined the inventory"
  end

  def decline
    authorize @invitation, :respond?
    @invitation.declined!
    redirect_to root_path, notice: "You have declined the invitation"
  end

  private

  def set_invitation
    @invitation = InventoryInvitation.find(params[:id])
  end

  def set_inventory
    @inventory = Inventory.find(params[:inventory_id])
  end

  def invitation_params
    params.require(:inventory_invitation).permit(:recipient_id, :role)
  end
end