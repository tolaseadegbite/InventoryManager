module Categories
  class CategoryManager
    attr_reader :category, :current_user, :inventory

    def initialize(category, current_user)
      @category = category
      @current_user = current_user
      @inventory = category.inventory
    end

    def create
      return false unless category.save
      
      log_creation
      true
    end

    def update(attributes)
      return false unless category.update(attributes)
      
      log_update if category.saved_changes.present?
      true
    end

    def destroy
      return false unless log_deletion && category.destroy
      true
    end

    private

    def log_creation
      ActivityLogs::ActivityLogService.create(
        user: current_user,
        inventory: inventory,
        action_type: :category_created,
        trackable: category,
        details: {
          name: category.name,
          created_by: current_user.profile.name,
          email: current_user.email_address,
          description: category.description
        }
      )
    end

    def log_update
      ActivityLogs::ActivityLogService.create(
        user: current_user,
        inventory: inventory,
        action_type: :category_updated,
        trackable: category,
        details: {
          name: category.name,
          updated_by: current_user.profile.name,
          email: current_user.email_address,
          changes: category.saved_changes.except('updated_at').transform_values { |v| [v[0].to_s, v[1].to_s] }
        }
      )
    end

    def log_deletion
      ActivityLogs::ActivityLogService.create(
        user: current_user,
        inventory: inventory,
        action_type: :category_deleted,
        trackable: category,
        details: {
          name: category.name,
          deleted_by: current_user.profile.name,
          email: current_user.email_address,
          items_count: category.items_count
        }
      )
    end
  end
end