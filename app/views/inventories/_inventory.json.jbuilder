json.extract! inventory, :id, :name, :description, :global_stock_threshold, :categories_count, :items_count, :inventory_actions_count, :user_id, :created_at, :updated_at
json.url inventory_url(inventory, format: :json)
