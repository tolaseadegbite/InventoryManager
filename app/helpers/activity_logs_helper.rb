module ActivityLogsHelper
  include Pagy::Frontend
  ACTION_TYPE_COLORS = {
    # Inventory related
    'inventory_created' => "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300",
    'inventory_updated' => "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300",
    'inventory_deleted' => "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300",
    
    # Item related
    'item_created' => "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300",
    'item_updated' => "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300",
    'item_deleted' => "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300",
    'quantity_changed' => "bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-300",
    'quantity_added' => "bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-300",
    'quantity_removed' => "bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-300",
    
    # Category related
    'category_created' => "bg-indigo-100 text-indigo-800 dark:bg-indigo-900/30 dark:text-indigo-300",
    'category_updated' => "bg-indigo-100 text-indigo-800 dark:bg-indigo-900/30 dark:text-indigo-300",
    'category_deleted' => "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300",
    
    # User management
    'user_added' => "bg-teal-100 text-teal-800 dark:bg-teal-900/30 dark:text-teal-300",
    'user_removed' => "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300",
    'role_changed' => "bg-cyan-100 text-cyan-800 dark:bg-cyan-900/30 dark:text-cyan-300",
    
    # Permissions
    'category_permission_granted' => "bg-lime-100 text-lime-800 dark:bg-lime-900/30 dark:text-lime-300",
    'category_permission_revoked' => "bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-300",
    
    # Invitations
    'invitation_sent' => "bg-sky-100 text-sky-800 dark:bg-sky-900/30 dark:text-sky-300",
    'invitation_accepted' => "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300",
    'invitation_declined' => "bg-rose-100 text-rose-800 dark:bg-rose-900/30 dark:text-rose-300",
    'invitation_cancelled' => "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300"
  }.freeze
  
  def action_type_badge_class(action_type)
    ACTION_TYPE_COLORS[action_type.to_s] || "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300"
  end
end