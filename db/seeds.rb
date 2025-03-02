# Clear existing data
[User, Inventory, Category, Item, InventoryAction, InventoryUser, CategoryPermission].each(&:destroy_all)

# Helper method to generate random email
def generate_email(name)
  "#{name.downcase.gsub(/\s+/, '.')}@test.com"
end

# Helper method to generate a random date within the last 6 months
def random_date_in_last_6_months
  rand(Time.now - 6.months..Time.now)
end

# Define roles array
roles = [:regular, :admin]

# Create 10 users plus test user
users = 10.times.map do |i|
  email = if i.zero?
    "tolase@test.com"
  else
    generate_email(Faker::Name.name)
  end
  password = i.zero? ? "foofoofoo" : "password"

  user = User.create!(
    email_address: email,
    password_digest: BCrypt::Password.create(password),
    status: :verified,
    role: i.zero? ? :admin : roles.sample,
    created_at: random_date_in_last_6_months,
    updated_at: random_date_in_last_6_months
  )

  Profile.create!(
    user: user,
    name: i.zero? ? "Tolase" : Faker::Name.name,
    created_at: user.created_at,
    updated_at: user.created_at
  )

  user
end

# Add test user
test_user = User.create!(
  email_address: "test@user.com",
  password_digest: BCrypt::Password.create("foofoofoo"),
  status: :verified,
  role: :regular,
  created_at: random_date_in_last_6_months,
  updated_at: random_date_in_last_6_months
)

Profile.create!(
  user: test_user,
  name: "Test User",
  created_at: test_user.created_at,
  updated_at: test_user.created_at
)

users << test_user

# Create 5 inventories for the first (manager) user
manager_user = users.first
inventory_names = ["Main Warehouse", "Secondary Warehouse", "Office Supplies", "Electronics Store", "Bookstore"]
inventories = 5.times.map do |i|
  # Create the inventory directly with timestamps
  inventory = Inventory.new(
    name: inventory_names[i],
    description: Faker::Lorem.sentence,
    global_stock_threshold: rand(5..20),
    user: manager_user,
    created_at: random_date_in_last_6_months,
    updated_at: random_date_in_last_6_months
  )
  
  # Use the service to create the inventory
  manager = Inventories::InventoryManager.new(inventory, manager_user)
  manager.create
  
  inventory
end

# Create 1 inventory for each of the remaining users
users[1..].each do |user|
  inventory_name = ["#{user.profile.name}'s Inventory", "Personal Warehouse", "Office Storage"].sample
  inventory = Inventory.new(
    name: inventory_name,
    description: Faker::Lorem.sentence,
    global_stock_threshold: rand(5..20),
    user: user,
    created_at: random_date_in_last_6_months,
    updated_at: random_date_in_last_6_months
  )
  
  # Use the service to create the inventory
  manager = Inventories::InventoryManager.new(inventory, user)
  manager.create
  
  inventories << inventory
end

# Create expanded eCommerce categories
category_names = [
  "Electronics", "Clothing", "Home & Kitchen", "Books", "Toys",
  "Sports Equipment", "Beauty Products", "Health Supplies", "Grocery",
  "Automotive Parts", "Office Supplies", "Garden & Outdoor",
  "Pet Supplies", "Musical Instruments", "Art Supplies",
  "Tools & Hardware", "Baby Products", "Stationery"
]

# Assign categories to all inventories
inventories.each do |inventory|
  # Determine how many categories to create
  num_categories = inventory.user == manager_user ? category_names.length : rand(3..6)
  
  # Select category names
  selected_categories = inventory.user == manager_user ? category_names : category_names.sample(num_categories)
  
  # Create categories
  selected_categories.each do |name|
    category = inventory.categories.build(
      name: name,
      description: Faker::Lorem.sentence,
      created_at: random_date_in_last_6_months,
      updated_at: random_date_in_last_6_months
    )
    
    # Use the service to create the category
    manager = Categories::CategoryManager.new(category, inventory.user)
    manager.create
  end
end

# Add some users as members to various inventories with different roles
inventories.each do |inventory|
  # Skip the first few users to ensure not everyone is in every inventory
  random_users = users.reject { |u| u == inventory.user }.sample(rand(2..4))
  
  random_users.each do |user|
    role = [:manager, :item_administrator, :viewer].sample # Include manager role in the possible roles
    
    inventory_user = inventory.inventory_users.build(
      user: user,
      role: role,
      created_at: random_date_in_last_6_months,
      updated_at: random_date_in_last_6_months
    )
    
    # Use the service to create the inventory user
    manager = InventoryUsers::InventoryUserManager.new(inventory_user, inventory.user)
    manager.create
    
    # Assign category permissions based on role
    if role == :manager
      # Managers get all categories
      inventory.categories.each do |category|
        permission = CategoryPermission.new(
          inventory_user: inventory_user,
          category: category,
          created_at: random_date_in_last_6_months,
          updated_at: random_date_in_last_6_months
        )
        
        # Use the service to create the permission
        permission_manager = CategoryPermissions::CategoryPermissionManager.new(permission, inventory.user)
        permission_manager.create
      end
    elsif role == :item_administrator
      # Item administrators get 50-80% of categories
      category_count = (inventory.categories.count * rand(0.5..0.8)).ceil
      categories_to_assign = inventory.categories.sample(category_count)
      
      categories_to_assign.each do |category|
        permission = CategoryPermission.new(
          inventory_user: inventory_user,
          category: category,
          created_at: random_date_in_last_6_months,
          updated_at: random_date_in_last_6_months
        )
        
        # Use the service to create the permission
        permission_manager = CategoryPermissions::CategoryPermissionManager.new(permission, inventory.user)
        permission_manager.create
      end
    elsif role == :viewer
      # Viewers get 30-60% of categories
      category_count = (inventory.categories.count * rand(0.3..0.6)).ceil
      categories_to_assign = inventory.categories.sample(category_count)
      
      categories_to_assign.each do |category|
        permission = CategoryPermission.new(
          inventory_user: inventory_user,
          category: category,
          created_at: random_date_in_last_6_months,
          updated_at: random_date_in_last_6_months
        )
        
        # Use the service to create the permission
        permission_manager = CategoryPermissions::CategoryPermissionManager.new(permission, inventory.user)
        permission_manager.create
      end
    end
  end
end

# Ensure that inventory owners (who are automatically managers) have permissions to all categories
Inventory.all.each do |inventory|
  # Find the manager inventory_user for the owner
  owner_inventory_user = inventory.inventory_users.find_by(user: inventory.user)
  
  # If for some reason the owner doesn't have an inventory_user record, create one
  unless owner_inventory_user
    owner_inventory_user = inventory.inventory_users.create!(
      user: inventory.user,
      role: :manager,
      created_at: inventory.created_at,
      updated_at: inventory.created_at
    )
  end
  
  # Ensure the owner has permissions for all categories
  inventory.categories.each do |category|
    # Skip if permission already exists
    next if CategoryPermission.exists?(inventory_user: owner_inventory_user, category: category)
    
    permission = CategoryPermission.new(
      inventory_user: owner_inventory_user,
      category: category,
      created_at: inventory.created_at,
      updated_at: inventory.created_at
    )
    
    # Use the service to create the permission
    permission_manager = CategoryPermissions::CategoryPermissionManager.new(permission, inventory.user)
    permission_manager.create
  end
end

# Create 10-15 items for each category
Inventory.all.each do |inventory|
  inventory.categories.each do |category|
    # Determine number of items based on inventory owner
    num_items = inventory.user == manager_user ? rand(10..15) : rand(5..10)
    
    num_items.times do
      item = Item.new(
        name: Faker::Commerce.product_name,
        description: Faker::Lorem.sentence,
        quantity: rand(0..100),
        stock_threshold: rand(0..20),
        category: category,
        inventory: inventory,
        user: inventory.user,
        created_at: random_date_in_last_6_months,
        updated_at: random_date_in_last_6_months
      )
      
      # Use the service to create the item
      manager = Items::ItemManager.new(item, inventory.user)
      manager.create
    end
  end
end

# Perform inventory actions with dates spread over time
puts "Creating inventory actions..."
Item.all.each do |item|
  # Create some removal actions
  rand(1..3).times do
    action_user = users.sample
    amount = rand(1..10)
    random_date = random_date_in_last_6_months
    
    # Create the inventory action directly
    action = InventoryAction.new(
      inventory: item.inventory,
      item: item,
      user: action_user,
      action_type: "remove",
      quantity: amount,
      notes: "Removed #{amount} units of #{item.name}",
      created_at: random_date,
      updated_at: random_date
    )
    
    # Save without validation to bypass callbacks
    action.save(validate: false)
    
    # Update the item quantity manually
    item.update_column(:quantity, [item.quantity - amount, 0].max)
  end

  # Create some addition actions
  rand(1..3).times do
    action_user = item.inventory.user
    amount = rand(10..50)
    random_date = random_date_in_last_6_months
    
    # Create the inventory action directly
    action = InventoryAction.new(
      inventory: item.inventory,
      item: item,
      user: action_user,
      action_type: "add",
      quantity: amount,
      notes: "Added #{amount} units of #{item.name}",
      created_at: random_date,
      updated_at: random_date
    )
    
    # Save without validation to bypass callbacks
    action.save(validate: false)
    
    # Update the item quantity manually
    item.update_column(:quantity, item.quantity + amount)
  end
  
  # Update the inventory_actions_count counter cache
  action_count = InventoryAction.where(item: item).count
  item.update_column(:inventory_actions_count, action_count)
end

# Set low stock status for about 20% of items in each inventory
Inventory.all.each do |inventory|
  low_stock_count = (inventory.items.count * 0.2).ceil
  inventory.items.sample(low_stock_count).each do |item|
    max_low_quantity = [inventory.global_stock_threshold - 1, 0].max
    
    # Update directly to avoid triggering service logic
    item.update_columns(
      quantity: rand(0..max_low_quantity),
      low_stock: true,
      updated_at: random_date_in_last_6_months
    )
  end
end

puts "Seeding completed successfully!"
puts "Total users: #{User.count}"
puts "Total inventories: #{Inventory.count}"
puts "Total categories: #{Category.count}"
puts "Total items: #{Item.count}"
puts "Total inventory actions: #{InventoryAction.count}"
puts "Total inventory actions: #{ActivityLog.count}"
puts "Low stock items: #{Item.where(low_stock: true).count}"
puts "Total inventory users: #{InventoryUser.count}"
puts "Users by role:"
puts "  Managers: #{InventoryUser.where(role: :manager).count}"
puts "  Item Administrators: #{InventoryUser.where(role: :item_administrator).count}"
puts "  Viewers: #{InventoryUser.where(role: :viewer).count}"
puts "Total category permissions: #{CategoryPermission.count}"