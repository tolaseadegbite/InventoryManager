module Inventories
  class InventoryManager
    attr_reader :inventory, :current_user

    def initialize(inventory, current_user)
      @inventory = inventory
      @current_user = current_user
    end

    def create
      return false unless inventory.save
      
      add_creator_as_manager
      log_creation
      true
    end

    def update(attributes)
      return false unless inventory.update(attributes)
      
      log_update if inventory.saved_changes.present?
      true
    end

    def destroy
      return false unless log_deletion && inventory.destroy
      true
    end

    def add_member(user, role = :viewer)
      # Fix: Use inventory.inventory_users instead of inventory_users
      inventory_user = inventory.inventory_users.build(user: user, role: role)
      manager = InventoryUsers::InventoryUserManager.new(inventory_user, current_user)
      manager.create
      inventory_user
    end
    
    def remove_member(user)
      inventory.inventory_users.find_by(user: user)&.destroy
    end

    private

    def add_creator_as_manager
      inventory.inventory_users.create!(
        user: inventory.user,
        role: :manager
      )
    end

    def log_creation
      ActivityLogs::ActivityLogService.create(
        user: inventory.user,
        inventory: inventory,
        action_type: :inventory_created,
        trackable: inventory,
        details: {
          name: inventory.name,
          created_by: inventory.user.profile.name,
          email: inventory.user.email_address,
          global_stock_threshold: inventory.global_stock_threshold
        }
      )
    end

    def log_update
      ActivityLogs::ActivityLogService.create(
        user: current_user,
        inventory: inventory,
        action_type: :inventory_updated,
        trackable: inventory,
        details: {
          name: inventory.name,
          updated_by: current_user.profile.name,
          email: current_user.email_address,
          changes: inventory.saved_changes.except('updated_at').transform_values { |v| [v[0].to_s, v[1].to_s] }
        }
      )
    end

    def log_deletion
      ActivityLogs::ActivityLogService.create(
        user: current_user,
        inventory: inventory,
        action_type: :inventory_deleted,
        trackable: inventory,
        details: {
          name: inventory.name,
          deleted_by: current_user.profile.name,
          email: current_user.email_address
        }
      )
    end
  end
end