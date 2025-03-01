class RoleChangedNotifier < ApplicationNotifier
  notification_methods do
    def message
      "Your role in #{params[:inventory].name} has been changed from #{params[:old_role]} to #{params[:new_role]} by #{params[:changed_by]}"
    end

    def url
      inventory_path(params[:inventory])
    end
  end
end