module Items
  class StockNotifierService
    attr_reader :item, :inventory, :quantity, :threshold

    def initialize(item)
      @item = item
      @inventory = item.inventory
      @quantity = item.quantity
      @threshold = item.effective_threshold
    end

    def notify_stock_change(is_low_stock)
      if is_low_stock
        notify_admins_of_stock_change
      else
        notify_admins_of_stock_replenishment
      end
    rescue => e
      Rails.logger.error "Failed to send stock notification: #{e.message}"
      # Optionally re-raise or handle the error differently
      false
    end

    private

    def notify_admins_of_stock_change
      LowStockNotifier.with(
        record_id: item.id,
        record: item,
        quantity: quantity,
        threshold: threshold,
        inventory_id: inventory.id,
        inventory_name: inventory.name
      ).deliver_later(User.where(role: :admin))
    end

    def notify_admins_of_stock_replenishment
      StockReplenishmentNotifier.with(
        record_id: item.id,
        record: item,
        quantity: quantity,
        threshold: threshold,
        inventory_id: inventory.id,
        inventory_name: inventory.name
      ).deliver_later(User.where(role: :admin))
    end
  end
end