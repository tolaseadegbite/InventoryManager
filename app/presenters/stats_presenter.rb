class StatsPresenter
  def initialize(inventory, inventory_user)
    @inventory = inventory
    @inventory_user = inventory_user
    @permitted_category_ids = inventory_user.manager? ? nil : inventory_user.permitted_categories.pluck(:id)
  end

  def data
    {
      total_items: total_items_count,
      low_stock_items: low_stock_items_count,
      categories_count: categories_count,
      users_count: @inventory.inventory_users.count
    }
  end

  private

  def total_items_count
    if @inventory_user.manager?
      @inventory.items.count
    else
      @inventory.items.where(category_id: @permitted_category_ids).count
    end
  end

  def low_stock_items_count
    if @inventory_user.manager?
      @inventory.items.low_stock.count
    else
      @inventory.items.low_stock.where(category_id: @permitted_category_ids).count
    end
  end

  def categories_count
    @inventory_user.manager? ? @inventory.categories.count : @inventory_user.permitted_categories.count
  end
end