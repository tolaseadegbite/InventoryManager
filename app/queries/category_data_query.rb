class CategoryDataQuery
  def initialize(inventory, inventory_user)
    @inventory = inventory
    @inventory_user = inventory_user
  end

  def fetch
    categories = if @inventory_user.manager?
      @inventory.categories
    else
      @inventory_user.permitted_categories
    end
    
    categories.map do |category|
      {
        name: category.name,
        count: category.items.count
      }
    end
  end
end