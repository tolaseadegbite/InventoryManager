# Disable the after_commit callback during seeding
Item.skip_callback(:commit, :after, :update_stock_status)

# Clear existing data
[User, Inventory, Category, Item, InventoryAction].each(&:destroy_all)

# Helper method to generate random email
def generate_email(name)
  "#{name.downcase.gsub(/\s+/, '.')}@test.com"
end

# Create 10 users
users = 10.times.map do |i|
  email = i.zero? ? "tolase@test.com" : generate_email(Faker::Name.name)
  password = i.zero? ? "foofoofoo" : "password"

  user = User.create!(
    email_address: email,
    password_digest: BCrypt::Password.create(password),
    status: :verified,
    role: i.zero? ? :admin : :regular
  )

  # Create profile
  Profile.create!(
    user: user,
    name: i.zero? ? "Tolase" : Faker::Name.name
  )

  user
end

# Create inventories for each user
inventories = users.map do |user|
  Inventory.create!(
    name: "#{user.profile.name}'s Inventory",
    description: Faker::Lorem.sentence,
    global_stock_threshold: rand(5..20),
    user: user
  )
end

# Create eCommerce categories
categories = ["Electronics", "Clothing", "Home & Kitchen", "Books", "Toys", 
              "Sports", "Beauty", "Health", "Grocery", "Automotive"]

# Create categories for the first inventory (main admin user)
main_inventory = inventories.first
categories.each do |name|
  Category.create!(
    name: name,
    description: Faker::Lorem.sentence,
    inventory: main_inventory
  )
end

# Create some categories for other inventories
inventories[1..].each do |inventory|
  rand(3..6).times do
    Category.create!(
      name: categories.sample,
      description: Faker::Lorem.sentence,
      inventory: inventory
    )
  end
end

# Create 100 items for the first inventory
100.times do
  Item.create!(
    name: Faker::Commerce.product_name,
    description: Faker::Lorem.sentence,
    quantity: rand(0..100),
    stock_threshold: rand(0..20),
    category: main_inventory.categories.sample,
    inventory: main_inventory,
    user: users.first
  )
end

# Create some items for other inventories
inventories[1..].each do |inventory|
  rand(10..30).times do
    Item.create!(
      name: Faker::Commerce.product_name,
      description: Faker::Lorem.sentence,
      quantity: rand(0..100),
      stock_threshold: rand(0..20),
      category: inventory.categories.sample,
      inventory: inventory,
      user: inventory.user
    )
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