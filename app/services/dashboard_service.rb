class DashboardService
  attr_reader :inventory, :user, :inventory_user

  def initialize(inventory, user)
    @inventory = inventory
    @user = user
    @inventory_user = user.inventory_users.find_by(inventory: inventory)
  end

  def fetch_data
    {
      activity_logs: cached_activity_logs,
      stats: cached_stats,
      low_stock_items: cached_low_stock_items,
      # low_stock_items: low_stock_items_query.fetch,
      category_data: cached_category_data,
      inventory_trends: cached_inventory_trends,
      category_overview: cached_category_overview
    }
  end

  private

  def cached_activity_logs
    Rails.cache.fetch(["dashboard_activity_logs", inventory.id, user.id, ActivityLog.maximum(:updated_at)&.to_i], expires_in: 5.minutes) do
      activity_logs_query.fetch
    end
  end

  def cached_stats
    Rails.cache.fetch(["dashboard_stats", inventory.id, user.id, inventory.updated_at.to_i], expires_in: 5.minutes) do
      stats_presenter.data
    end
  end

  def cached_low_stock_items
    Rails.cache.fetch(["dashboard_low_stock", inventory.id, user.id, inventory.items.maximum(:updated_at)&.to_i], expires_in: 5.minutes) do
      low_stock_items_query.fetch
    end
  end

  def cached_category_data
    Rails.cache.fetch(["dashboard_category_data", inventory.id, user.id, inventory.categories.maximum(:updated_at)&.to_i], expires_in: 5.minutes) do
      category_data_query.fetch
    end
  end

  def cached_inventory_trends
    Rails.cache.fetch(["dashboard_inventory_trends", inventory.id, user.id, inventory.items.maximum(:created_at)&.to_i], expires_in: 1.hour) do
      inventory_trends_query.fetch
    end
  end

  def cached_category_overview
    Rails.cache.fetch(["dashboard_category_overview", inventory.id, user.id, 
                      inventory.categories.maximum(:updated_at)&.to_i,
                      CategoryPermission.where(category_id: inventory.categories.pluck(:id)).maximum(:updated_at)&.to_i], 
                      expires_in: 5.minutes) do
      category_overview_query.fetch
    end
  end

  def activity_logs_query
    ActivityLogsQuery.new(inventory, user, inventory_user, limit: 5)
  end

  def stats_presenter
    StatsPresenter.new(inventory, inventory_user)
  end

  def low_stock_items_query
    LowStockItemsQuery.new(inventory, inventory_user, limit: 6)
  end

  def category_data_query
    CategoryDataQuery.new(inventory, inventory_user)
  end

  def inventory_trends_query
    InventoryTrendsQuery.new(inventory, inventory_user, months: 6)
  end

  def category_overview_query
    CategoryOverviewQuery.new(inventory, inventory_user)
  end
end