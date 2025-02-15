class InventoryInvitationDeclinedNotifier < ApplicationNotifier
  notification_methods do
    def message
      "#{params[:invitation].recipient.profile&.name || params[:invitation].recipient.email} " \
      "has declined your request to join #{params[:inventory].name} as #{params[:role]}"
    end

    def url
      inventory_path(params[:inventory])
    end
  end
end