class InventoryInvitationNotifier < ApplicationNotifier
  notification_methods do
    def message
      "#{params[:invitation].sender.profile&.name || params[:invitation].sender.email} " \
      "has invited you to join #{params[:inventory].name} as #{params[:role]}"
    end

    def url
      inventory_path(params[:inventory])
    end
  end
end