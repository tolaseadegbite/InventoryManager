# app/notifiers/category_permissions_updated_notifier.rb
class CategoryPermissionsUpdatedNotifier < ApplicationNotifier
  notification_methods do
    def message
      "Your category permissions have been updated in #{params[:inventory].name}"
    end

    def url
      inventory_path(params[:inventory])
    end
  end
end