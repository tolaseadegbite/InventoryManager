class LowStockItemsQuery
  def initialize(inventory, inventory_user, limit: 6)
    @inventory = inventory
    @inventory_user = inventory_user
    @limit = limit
  end

  def fetch
    if @inventory_user.manager?
      @inventory.items.low_stock
                .includes(:category)
                .order(quantity: :asc)
                .limit(@limit)
    else
      category_ids = @inventory_user.permitted_categories.pluck(:id)
      @inventory.items.low_stock
                .where(category_id: category_ids)
                .includes(:category)
                .order(quantity: :asc)
                .limit(@limit)
    end
  end
end