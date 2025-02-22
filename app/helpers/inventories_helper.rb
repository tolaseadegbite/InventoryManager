module InventoriesHelper
  def inventory_owner_badge(inventory)
    return unless inventory.user_id != Current.user.id
    
    content_tag :span, class: "text-xs font-medium bg-gray-100 text-gray-800 px-2.5 py-0.5 rounded-full" do
      "Owner: #{inventory.user.profile&.name || inventory.user.email}"
    end
  end

  def inventory_association_badge(inventory)
    return unless inventory.user_id != Current.user.id
    
    inventory_user = inventory.inventory_users.find_by(user: current_user)
    content_tag :span, class: "text-xs font-medium bg-gray-100 text-gray-800 px-2.5 py-0.5 rounded-full" do
      "Shared: #{inventory_user&.role.titleize}"
    end
  end

  def inventory_manager?(inventory)
    return false if current_user.nil?

    inventory_user = inventory.inventory_users.find_by(user: current_user)
    inventory_user&.manager?
  end

  def permitted_category?(inventory, category)
    return false if current_user.nil?

    inventory_user = inventory.inventory_users.find_by(user: current_user)
    return false if inventory_user.nil?

    inventory_user.permitted_categories.include?(category)
  end
end
