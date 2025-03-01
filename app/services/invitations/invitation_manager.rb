module Invitations
  class InvitationManager
    attr_reader :invitation, :current_user

    def initialize(invitation, current_user)
      @invitation = invitation
      @current_user = current_user
    end

    def create
      return false unless invitation.valid?
      
      if invitation.save
        notify_recipient
        log_invitation_sent
        true
      else
        false
      end
    end

    def accept
      return false unless invitation.pending?
      
      invitation.transaction do
        invitation.accepted!
        invitation.inventory.add_member(invitation.recipient, invitation.role)
        log_invitation_accepted
        notify_sender_of_acceptance
      end
      true
    rescue => e
      Rails.logger.error "Failed to accept invitation: #{e.message}"
      false
    end

    def decline
      return false unless invitation.pending?
      
      invitation.transaction do
        invitation.declined!
        log_invitation_declined
        notify_sender_of_decline
      end
      true
    rescue => e
      Rails.logger.error "Failed to decline invitation: #{e.message}"
      false
    end

    def cancel
      return false unless invitation.pending?
      
      if invitation.destroy
        log_invitation_cancelled
        true
      else
        false
      end
    end

    private

    def notify_recipient
      InventoryInvitationNotifier.with(
        record_id: invitation.id,
        record: invitation,
        invitation: invitation,
        inventory: invitation.inventory,
        role: invitation.role
      ).deliver_later(invitation.recipient)
    end
    
    def notify_sender_of_acceptance
      InventoryInvitationAcceptedNotifier.with(
        record_id: invitation.id,
        record: invitation,
        invitation: invitation,
        inventory: invitation.inventory,
        user: invitation.recipient,
        role: invitation.role
      ).deliver_later(invitation.sender)
    end
    
    def notify_sender_of_decline
      InventoryInvitationDeclinedNotifier.with(
        record_id: invitation.id,
        record: invitation,
        invitation: invitation,
        inventory: invitation.inventory,
        user: invitation.recipient,
        role: invitation.role
      ).deliver_later(invitation.sender)
    end

    def log_invitation_sent
      ActivityLogs::ActivityLogService.create(
        user: invitation.sender,
        inventory: invitation.inventory,
        action_type: :invitation_sent,
        trackable: invitation,
        details: {
          recipient_email: invitation.recipient.email_address,
          role: invitation.role
        }
      )
    end

    def log_invitation_accepted
      ActivityLogs::ActivityLogService.create(
        user: invitation.recipient,
        inventory: invitation.inventory,
        action_type: :invitation_accepted,
        trackable: invitation,
        details: {
          sender_name: invitation.sender.profile.name,
          recipient_name: invitation.recipient.profile.name,
          role: invitation.role
        }
      )
    end

    def log_invitation_declined
      ActivityLogs::ActivityLogService.create(
        user: invitation.recipient,
        inventory: invitation.inventory,
        action_type: :invitation_declined,
        trackable: invitation,
        details: {
          sender_name: invitation.sender.profile.name,
          recipient_name: invitation.recipient.profile.name,
          role: invitation.role
        }
      )
    end

    def log_invitation_cancelled
      ActivityLogs::ActivityLogService.create(
        user: current_user,
        inventory: invitation.inventory,
        action_type: :invitation_cancelled,
        trackable: invitation,
        details: {
          recipient_email: invitation.recipient.email_address,
          role: invitation.role
        }
      )
    end
  end
end