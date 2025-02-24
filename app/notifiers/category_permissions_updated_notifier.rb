# app/notifiers/category_permissions_updated_notifier.rb
class CategoryPermissionsUpdatedNotifier < ApplicationNotifier
  notification_methods do
    def message
      "Your category permissions have been updated in #{params[:inventory].name}"
    end

    def url
      inventory_inventory_user_path(params[:inventory], params[:inventory_user], tab: 'categories')
    end
  end
end