class InventoryInvitationNotifier < ApplicationNotifier
  notification_methods do
    def message
      "#{params[:invitation].sender.profile&.name || params[:invitation].sender.email} " \
      "has invited you to join #{params[:inventory].name} as #{params[:role].titleize}"
    end

    def url
      inventory_path(params[:inventory])
    end

    def actions
      [
        {
          label: "Accept",
          url: accept_inventory_invitation_path(params[:invitation]),
          method: :post,
          classes: "btn btn-primary btn-sm"
        },
        {
          label: "Decline",
          url: decline_inventory_invitation_path(params[:invitation]),
          method: :post,
          classes: "btn btn-outline-danger btn-sm"
        }
      ]
    end
  end
end