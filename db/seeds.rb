# Disable the after_commit callback during seeding
Item.skip_callback(:commit, :after, :update_stock_status)

# Clear existing data
[User, Inventory, Category, Item, InventoryAction, InventoryUser].each(&:destroy_all)

# Helper method to generate random email
def generate_email(name)
  "#{name.downcase.gsub(/\s+/, '.')}@test.com"
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
    role: i.zero? ? :admin : roles.sample
  )

  Profile.create!(
    user: user,
    name: i.zero? ? "Tolase" : Faker::Name.name
  )

  user
end

# Add test user
test_user = User.create!(
  email_address: "test@user.com",
  password_digest: BCrypt::Password.create("foofoofoo"),
  status: :verified,
  role: :regular
)

Profile.create!(
  user: test_user,
  name: "Test User"
)

users << test_user

# Create 5 inventories for the first (manager) user
manager_user = users.first
inventory_names = ["Main Warehouse", "Secondary Warehouse", "Office Supplies", "Electronics Store", "Bookstore"]
inventories = 5.times.map do |i|
  Inventory.create!(
    name: inventory_names[i],
    description: Faker::Lorem.sentence,
    global_stock_threshold: rand(5..20),
    user: manager_user
  )
end

# Create 1 inventory for each of the remaining users
users[1..].each do |user|
  inventory_name = ["#{user.profile.name}'s Inventory", "Personal Warehouse", "Office Storage"].sample
  inventories << Inventory.create!(
    name: inventory_name,
    description: Faker::Lorem.sentence,
    global_stock_threshold: rand(5..20),
    user: user
  )
end

# Add some users as members to various inventories with different roles
inventories.each do |inventory|
  # Skip the first few users to ensure not everyone is in every inventory
  random_users = users.reject { |u| u == inventory.user }.sample(rand(2..4))
  
  random_users.each do |user|
    inventory.inventory_users.create!(
      user: user,
      role: [:item_administrator, :viewer].sample
    )
  end
end

# Create expanded eCommerce categories
categories = [
  "Electronics", "Clothing", "Home & Kitchen", "Books", "Toys",
  "Sports Equipment", "Beauty Products", "Health Supplies", "Grocery",
  "Automotive Parts", "Office Supplies", "Garden & Outdoor",
  "Pet Supplies", "Musical Instruments", "Art Supplies",
  "Tools & Hardware", "Baby Products", "Stationery"
]

# Assign categories to the manager's inventories
manager_inventories = inventories.select { |inv| inv.user == manager_user }
manager_inventories.each do |inventory|
  categories.each do |name|
    Category.create!(
      name: name,
      description: Faker::Lorem.sentence,
      inventory: inventory
    )
  end
end

# Assign random categories to other inventories
inventories.reject { |inv| inv.user == manager_user }.each do |inventory|
  rand(3..6).times do
    Category.create!(
      name: categories.sample,
      description: Faker::Lorem.sentence,
      inventory: inventory
    )
  end
end

# Create 50-70 items for each category in manager's inventories
manager_inventories.each do |inventory|
  inventory.categories.each do |category|
    rand(50..70).times do
      Item.create!(
        name: Faker::Commerce.product_name,
        description: Faker::Lorem.sentence,
        quantity: rand(0..100),
        stock_threshold: rand(0..20),
        category: category,
        inventory: inventory,
        user: manager_user
      )
    end
  end
end

# Create 50-70 items for each category in other inventories
inventories.reject { |inv| inv.user == manager_user }.each do |inventory|
  inventory.categories.each do |category|
    rand(50..70).times do
      Item.create!(
        name: Faker::Commerce.product_name,
        description: Faker::Lorem.sentence,
        quantity: rand(0..100),
        stock_threshold: rand(0..20),
        category: category,
        inventory: inventory,
        user: inventory.user
      )
    end
  end
end

# Perform inventory actions
Item.all.each do |item|
  # Create some removal actions
  rand(2..5).times do
    amount = rand(1..10)
    InventoryAction.create!(
      inventory: item.inventory,
      item: item,
      user: users.sample,
      action_type: "remove",
      quantity: amount,
      notes: "Removed #{amount} units of #{item.name}"
    )
    item.update!(quantity: [item.quantity - amount, 0].max)
  end

  # Create some addition actions
  rand(2..5).times do
    amount = rand(10..50)
    InventoryAction.create!(
      inventory: item.inventory,
      item: item,
      user: item.inventory.user,
      action_type: "add",
      quantity: amount,
      notes: "Added #{amount} units of #{item.name}"
    )
    item.update!(quantity: item.quantity + amount)
  end
end

# Set low stock status for about 20% of items in each inventory
Inventory.all.each do |inventory|
  low_stock_count = (inventory.items.count * 0.2).ceil
  inventory.items.sample(low_stock_count).each do |item|
    max_low_quantity = [inventory.global_stock_threshold - 1, 0].max
    item.update!(
      quantity: rand(0..max_low_quantity),
      low_stock: true
    )
  end
end

# Re-enable callback
Item.set_callback(:commit, :after, :update_stock_status)

puts "Seeding completed successfully!"
puts "Total users: #{User.count}"
puts "Total inventories: #{Inventory.count}"
puts "Total categories: #{Category.count}"
puts "Total items: #{Item.count}"
puts "Total inventory actions: #{InventoryAction.count}"
puts "Low stock items: #{Item.where(low_stock: true).count}"
puts "Total inventory users: #{InventoryUser.count}"
puts "Users by role:"
puts "  Managers: #{InventoryUser.where(role: :manager).count}"
puts "  Item Administrators: #{InventoryUser.where(role: :item_administrator).count}"
puts "  Viewers: #{InventoryUser.where(role: :viewer).count}"