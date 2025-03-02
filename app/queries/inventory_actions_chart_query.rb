class InventoryActionsChartQuery
  def initialize(inventory, days = 30)
    @inventory = inventory
    @days = days
  end

  def fetch
    # Get data for the last X days
    start_date = @days.days.ago.beginning_of_day
    end_date = Time.current.end_of_day
    
    # Get all inventory actions in the period
    actions = @inventory.inventory_actions
      .where(created_at: start_date..end_date)
      .group("DATE(created_at)")
      .group(:action_type)
      .count
    
    # Format the data for the chart
    result = []
    
    # Create a date range for all days in the period
    (start_date.to_date..end_date.to_date).each do |date|
      day_data = {
        date: date.strftime("%b %d"),
        add: 0,
        remove: 0,
        adjust: 0
      }
      
      # Fill in actual counts
      actions.each do |(action_date, action_type), count|
        if Date.parse(action_date.to_s) == date && day_data.key?(action_type.to_sym)
          day_data[action_type.to_sym] = count
        end
      end
      
      result << day_data
    end
    
    result
  end
end