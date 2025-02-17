class InventoryInvitationsController < ApplicationController
  before_action :set_inventory, except: [:accept, :decline]
  before_action :set_invitation, only: [:accept, :decline, :destroy, :confirm_delete]

  def new
    @invitation = @inventory.inventory_invitations.new
  end

  def create
    @invitation = @inventory.inventory_invitations.new(invitation_params)
    @invitation.sender = Current.user
    
    if @inventory.can_invite?(@invitation.recipient) && @invitation.save
      redirect_to inventory_inventory_users_path(@inventory, tab: 'invitations'), 
                  notice: "Invitation sent successfully"
    else
      flash.now[:alert] = "Failed to create invitation. Please check the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  def accept
    authorize @invitation, :respond?
    
    if @invitation.pending?
      @invitation.accepted!
      redirect_to inventory_path(@invitation.inventory), 
                  notice: "You have joined the inventory"
    else
      redirect_to root_path, 
                  alert: "This invitation is no longer valid"
    end
  end

  def decline
    authorize @invitation, :respond?
    
    if @invitation.pending?
      @invitation.declined!
      redirect_to root_path, 
                  notice: "You have declined the invitation"
    else
      redirect_to root_path, 
                  alert: "This invitation is no longer valid"
    end
  end

  def destroy
    @invitation.destroy
    redirect_to inventory_inventory_users_path(@inventory, tab: 'invitations'), notice: "You have canceled the invitation"
  end

  def confirm_delete
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