class InventoryTrendsQuery
  def initialize(inventory, inventory_user, months: 6)
    @inventory = inventory
    @inventory_user = inventory_user
    @months = months
  end

  def fetch
    months_range = @months.times.map { |i| (Date.today - i.months).beginning_of_month }
    
    if @inventory_user.manager?
      manager_trends(months_range)
    else
      user_trends(months_range)
    end
  end

  private

  def manager_trends(months_range)
    months_range.map do |month|
      {
        month: month.strftime("%b"),
        count: @inventory.items.where("created_at <= ?", month.end_of_month).count
      }
    end.reverse
  end

  def user_trends(months_range)
    category_ids = @inventory_user.permitted_categories.pluck(:id)
    months_range.map do |month|
      {
        month: month.strftime("%b"),
        count: @inventory.items.where("created_at <= ? AND category_id IN (?)", 
                                    month.end_of_month, category_ids).count
      }
    end.reverse
  end
end