module Items
  class ItemManager
    attr_reader :item, :current_user, :inventory

    def initialize(item, current_user)
      @item = item
      @current_user = current_user
      @inventory = item.inventory
    end

    def create
      return false unless item.save
      
      log_activity(:item_created, {
        name: item.name,
        category: item.category&.name,
        quantity: item.quantity
      })
      
      check_stock_status
      true
    end

    def update(attributes)
      original_attributes = item.attributes.dup
      return false unless item.update(attributes)
      
      unless quantity_only_change?(item.saved_changes)
        log_activity(:item_updated, {
          changes: item.saved_changes.except('updated_at'),
          name: item.name
        })
      end
      
      check_stock_status if should_check_stock?(original_attributes)
      true
    end

    def destroy
      return false unless item.destroy
      
      log_activity(:item_deleted, {
        name: item.name,
        category: item.category&.name
      })
      true
    end

    def modify_quantity(action, amount, notes = nil)
      return false if invalid_quantity_modification?(action, amount)
      
      ApplicationRecord.transaction do
        original_quantity = item.quantity
        new_quantity = calculate_new_quantity(action, amount)
        
        item.update_column(:quantity, new_quantity)
        create_inventory_action(action, amount, notes)
        log_quantity_change(action, amount, original_quantity, new_quantity, notes)
        check_stock_status
      end
      true
    rescue => e
      Rails.logger.error "Failed to #{action} quantity: #{e.message}"
      item.errors.add(:base, e.message)
      false
    end

    private

    def invalid_quantity_modification?(action, amount)
      return true if amount.nil? || amount <= 0
      return true if action == "remove" && amount > item.quantity
      return true unless Item::VALID_ACTIONS.include?(action)
      false
    end

    def calculate_new_quantity(action, amount)
      action == "add" ? item.quantity + amount : item.quantity - amount
    end

    def create_inventory_action(action, amount, notes)
      item.inventory_actions.create!(
        inventory: inventory,
        user: current_user,
        action_type: action,
        quantity: amount,
        notes: notes
      )
    end

    def log_quantity_change(action, amount, original_quantity, new_quantity, notes)
      ActivityLogs::ActivityLogService.create(
        user: current_user,
        inventory: inventory,
        action_type: :quantity_changed,
        trackable: item,
        details: {
          action: action,
          amount: amount,
          from: original_quantity,
          to: new_quantity,
          notes: notes
        }
      )
    end

    def log_activity(action_type, details)
      ActivityLogs::ActivityLogService.create(
        user: action_type == :item_updated ? Current.user : current_user,
        inventory: inventory,
        action_type: action_type,
        trackable: item,
        details: details
      )
    end

    def check_stock_status
      return unless item.quantity.present?
      
      current_low_stock = item.quantity <= effective_threshold
      return if current_low_stock == item.low_stock
      
      item.update_column(:low_stock, current_low_stock)
      notify_stock_change(current_low_stock)
    end

    def notify_stock_change(is_low_stock)
      if is_low_stock
        notify_admins_of_stock_change
      else
        notify_admins_of_stock_replenishment
      end
    end

    def notify_stock_change(is_low_stock)
      Items::StockNotifierService.new(item).notify_stock_change(is_low_stock)
    end

    def effective_threshold
      item.stock_threshold.zero? ? inventory.global_stock_threshold : item.stock_threshold
    end

    def should_check_stock?(original_attributes)
      item.quantity != original_attributes["quantity"] ||
      item.stock_threshold != original_attributes["stock_threshold"] ||
      (inventory.saved_change_to_global_stock_threshold? && item.stock_threshold.zero?)
    end

    def quantity_only_change?(changes)
      changes.keys == ['quantity'] || changes.keys == ['quantity', 'updated_at']
    end
  end
end