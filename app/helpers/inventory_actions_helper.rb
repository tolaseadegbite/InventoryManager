module InventoryActionsHelper
  INVENTORY_ACTION_COLORS = {
    'add' => "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300",
    'remove' => "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300",
    'adjust' => "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300",
    'transfer_in' => "bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-300",
    'transfer_out' => "bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-300"
  }.freeze
  
  def inventory_action_badge_class(action_type)
    INVENTORY_ACTION_COLORS[action_type.to_s] || "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300"
  end
end