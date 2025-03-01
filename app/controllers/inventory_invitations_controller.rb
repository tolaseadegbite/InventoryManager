class InventoryInvitationsController < ApplicationController
  before_action :set_inventory, except: [:accept, :decline]
  before_action :set_invitation, only: [:accept, :decline, :destroy, :confirm_delete]

  def new
    @invitation = @inventory.inventory_invitations.new
  end

  def create
    @invitation = @inventory.inventory_invitations.new(invitation_params)
    @invitation.sender = Current.user
    
    if @inventory.can_invite?(@invitation.recipient)
      manager = Invitations::InvitationManager.new(@invitation, Current.user)
      
      if manager.create
        redirect_to inventory_inventory_users_path(@inventory, tab: 'invitations'), 
                    notice: "Invitation sent successfully"
      else
        flash.now[:alert] = "Failed to create invitation. Please check the errors below."
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Failed to create invitation. User cannot be invited."
      render :new, status: :unprocessable_entity
    end
  end

  def accept
    authorize @invitation, :respond?
    
    manager = Invitations::InvitationManager.new(@invitation, Current.user)
    
    if manager.accept
      redirect_to inventory_path(@invitation.inventory), 
                  notice: "You have joined the inventory"
    else
      redirect_to root_path, 
                  alert: "This invitation is no longer valid"
    end
  end

  def decline
    authorize @invitation, :respond?
    
    manager = Invitations::InvitationManager.new(@invitation, Current.user)
    
    if manager.decline
      redirect_to root_path, 
                  notice: "You have declined the invitation"
    else
      redirect_to root_path, 
                  alert: "This invitation is no longer valid"
    end
  end

  def destroy
    manager = Invitations::InvitationManager.new(@invitation, Current.user)
    
    if manager.cancel
      redirect_to inventory_inventory_users_path(@inventory, tab: 'invitations'), 
                  notice: "You have canceled the invitation"
    else
      redirect_to inventory_inventory_users_path(@inventory, tab: 'invitations'), 
                  alert: "Failed to cancel the invitation"
    end
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