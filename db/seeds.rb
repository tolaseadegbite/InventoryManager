# Disable the after_commit callback during seeding
Item.skip_callback(:commit, :after, :update_stock_status)

# Clear existing data
[User, Category, Item, InventoryAction].each(&:destroy_all)

# Helper method to generate random email
def generate_email(name)
  "#{name.downcase.gsub(/\s+/, '.')}@test.com"
end

# Create 10 verified users
users = 10.times.map do |i|
  email = i.zero? ? "tolase@test.com" : generate_email(Faker::Name.name)
  password = i.zero? ? "foofoofoo" : "password"
  global_threshold = i.zero? ? 10 : rand(5..20)

  user = User.create!(
    email_address: email,
    password_digest: BCrypt::Password.create(password),
    status: :verified,
    role: i.zero? ? :admin : :regular,
    global_stock_threshold: global_threshold
  )

  # Create profile
  Profile.create!(
    user: user,
    name: i.zero? ? "Tolase" : Faker::Name.name
  )

  user
end

# Create eCommerce categories
categories = ["Electronics", "Clothing", "Home & Kitchen", "Books", "Toys", 
              "Sports", "Beauty", "Health", "Grocery", "Automotive"]
categories.each do |name|
  Category.create!(
    name: name,
    user: users.first,
    description: Faker::Lorem.sentence
  )
end

# Create 100 items for the first user
100.times do
  Item.create!(
    name: Faker::Commerce.product_name,
    description: Faker::Lorem.sentence,
    quantity: rand(0..100),
    category: Category.all.sample,
    user: users.first,
    stock_threshold: rand(0..20)
  )
end

# Perform inventory actions
items = Item.all

# Remove items
users.each do |user|
  rand(5..15).times do
    item = items.sample
    amount = rand(1..10)
    item.modify_quantity(
      "remove",
      amount,
      user,
      "Removed #{amount} units of #{item.name}"
    )
  end
end

# Restock items as admin
items.each do |item|
  amount = rand(10..50)
  item.modify_quantity(
    "add",
    amount,
    users.first,
    "Added #{amount} units of #{item.name}"
  )
end

# Correctly set low stock items using effective threshold
low_stock_count = (Item.count * 0.2).ceil
Item.all.sample(low_stock_count).each do |item|
  effective_threshold = item.stock_threshold.zero? ? item.user.global_stock_threshold : item.stock_threshold
  max_low_quantity = [effective_threshold - 1, 0].max # Ensure quantity is below threshold
  item.update_columns(quantity: rand(0..max_low_quantity))
end

# Update low_stock status for all items
Item.find_each do |item|
  effective_threshold = item.stock_threshold.zero? ? item.user.global_stock_threshold : item.stock_threshold
  item.update_columns(low_stock: item.quantity <= effective_threshold)
end

# Re-enable callback
Item.set_callback(:commit, :after, :update_stock_status)

puts "Seeding completed successfully!"
puts "#{Item.low_stock.count} items marked as low stock"