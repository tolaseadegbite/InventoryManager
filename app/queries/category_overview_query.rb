class CategoryOverviewQuery
  def initialize(inventory, inventory_user)
    @inventory = inventory
    @inventory_user = inventory_user
  end

  def fetch
    categories = if @inventory_user.manager?
      @inventory.categories.includes(:items)
    else
      @inventory_user.permitted_categories.includes(:items)
    end
    
    categories.map do |category|
      build_category_data(category)
    end
  end

  private

  def build_category_data(category)
    items = category.items
    last_activity = ActivityLog.where(trackable: category)
                              .or(ActivityLog.where(trackable: items))
                              .order(created_at: :desc)
                              .first

    permissions = CategoryPermission.includes(inventory_user: { user: :profile })
                                    .where(category_id: category.id)
    
    permitted_users = permissions.map do |permission|
      inventory_user = permission.inventory_user
      user = inventory_user.user
      profile = user.profile
      
      {
        name: profile.name,
        inventory_user_id: inventory_user.id,
        has_avatar: profile.avatar.attached?,
        avatar_url: profile.avatar.attached? ? Rails.application.routes.url_helpers.url_for(profile.avatar) : nil,
        role: inventory_user.role
      }
    end
    
    {
      id: category.id,
      name: category.name,
      total_items: items.count,
      low_stock: items.select(&:low_stock).count,
      permitted_users: permitted_users,
      last_activity_at: last_activity&.created_at
    }
  end
end