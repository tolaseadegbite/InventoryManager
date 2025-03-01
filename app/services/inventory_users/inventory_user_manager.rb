module InventoryUsers
  class InventoryUserManager
    attr_reader :inventory_user, :current_user, :inventory

    def initialize(inventory_user, current_user)
      @inventory_user = inventory_user
      @current_user = current_user
      @inventory = inventory_user.inventory
    end

    def create
      return false unless inventory_user.save
      
      process_new_user
      true
    end

    def update(attributes)
      old_role = inventory_user.role
      
      return false unless inventory_user.update(attributes)
      
      log_role_change(old_role) if inventory_user.role != old_role
      true
    end

    def destroy
      return false unless log_user_removed && inventory_user.destroy
      true
    end

    private

    def process_new_user
      check_role_permissions
      assign_categories_if_manager
      log_user_added
    end

    def check_role_permissions
      return if inventory_user.manager?
      # Any additional role-specific setup can go here
    end

    def assign_categories_if_manager
      return unless inventory_user.manager?
      
      inventory.categories.find_each do |category|
        inventory_user.category_permissions.create!(category: category)
      end
    end

    def log_user_added
      ActivityLogs::ActivityLogService.create(
        user: current_user || inventory_user.user,
        inventory: inventory,
        action_type: :user_added,
        trackable: inventory_user,
        details: {
          user_name: inventory_user.user.profile.name,
          role: inventory_user.role.titleize,
          added_by: current_user&.profile&.name || 'System',
          email: inventory_user.user.email_address
        }
      )
    end

    def log_role_change(old_role)
      ActivityLogs::ActivityLogService.create(
        user: current_user,
        inventory: inventory,
        action_type: :role_changed,
        trackable: inventory_user,
        details: {
          user_name: inventory_user.user.profile.name,
          email: inventory_user.user.email_address,
          old_role: old_role.titleize,
          new_role: inventory_user.role.titleize,
          changed_by: current_user.profile.name
        }
      )
    end

    def log_user_removed
      ActivityLogs::ActivityLogService.create(
        user: current_user,
        inventory: inventory,
        action_type: :user_removed,
        trackable: inventory_user,
        details: {
          user_name: inventory_user.user.profile.name,
          email: inventory_user.user.email_address,
          role: inventory_user.role.titleize,
          removed_by: current_user.profile.name
        }
      )
    end
  end
end