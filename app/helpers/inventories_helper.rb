module InventoriesHelper
  def inventory_owner_badge(inventory)
    return unless inventory.user_id != Current.user.id
    
    content_tag :span, class: "text-xs font-medium bg-gray-100 text-gray-800 px-2.5 py-0.5 rounded-full" do
      "Owner: #{inventory.user.profile&.name || inventory.user.email}"
    end
  end
end
