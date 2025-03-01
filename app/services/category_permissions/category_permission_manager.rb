module CategoryPermissions
  class CategoryPermissionManager
    attr_reader :category_permission, :current_user, :inventory

    def initialize(category_permission, current_user)
      @category_permission = category_permission
      @current_user = current_user
      @inventory = category_permission.inventory_user.inventory
    end

    def create
      return false unless category_permission.save
      
      log_permission_granted
      true
    end

    def destroy
      return false unless log_permission_revoked && category_permission.destroy
      true
    end

    def update_permissions(inventory_user, new_category_ids)
      # Get current category permissions
      current_category_ids = inventory_user.category_permissions.pluck(:category_id)
      
      # Find categories to remove and add
      categories_to_remove = current_category_ids - new_category_ids
      categories_to_add = new_category_ids - current_category_ids
      
      ActiveRecord::Base.transaction do
        # Remove permissions no longer needed
        if categories_to_remove.any?
          inventory_user.category_permissions.where(category_id: categories_to_remove).each do |permission|
            manager = CategoryPermissions::CategoryPermissionManager.new(permission, current_user)
            manager.destroy
          end
        end
        
        # Add new permissions
        categories_to_add.each do |category_id|
          permission = inventory_user.category_permissions.build(category_id: category_id)
          manager = CategoryPermissions::CategoryPermissionManager.new(permission, current_user)
          manager.create
        end
        
        # Send notification if changes were made
        if categories_to_remove.any? || categories_to_add.any?
          CategoryPermissionsUpdatedNotifier.with(
            inventory_user: inventory_user,
            inventory: inventory_user.inventory
          ).deliver_later(inventory_user.user)
        end
        
        true
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Permission update failed: #{e.message}")
      false
    end

    private

    def log_permission_granted
      ActivityLogs::ActivityLogService.create(
        user: current_user,
        inventory: inventory,
        action_type: :category_permission_granted,
        trackable: category_permission,
        details: {
          user_name: category_permission.inventory_user.user.profile.name,
          category_name: category_permission.category.name,
          role: category_permission.inventory_user.role.titleize
        }
      )
    end

    def log_permission_revoked
      ActivityLogs::ActivityLogService.create(
        user: current_user,
        inventory: inventory,
        action_type: :category_permission_revoked,
        trackable: category_permission,
        details: {
          user_name: category_permission.inventory_user.user.profile.name,
          category_name: category_permission.category.name
        }
      )
    end
  end
end