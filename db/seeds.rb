# Disable the after_commit callback during seeding
Item.skip_callback(:commit, :after, :update_stock_status)

# Clear existing data
User.destroy_all
Category.destroy_all
Item.destroy_all
InventoryAction.destroy_all

# Helper method to generate random email
def generate_email(name)
  "#{name.downcase.gsub(/\s+/, '.')}@test.com"
end

# Create 10 verified users
users = []
10.times do |i|
  email_address = i == 0 ? "tolase@test.com" : generate_email(Faker::Name.name)
  password = i == 0 ? "foofoofoo" : "password"
  global_stock_threshold = i == 0 ? 10 : rand(5..20)

  user = User.create!(
    email_address: email_address,
    password_digest: BCrypt::Password.create(password),
    status: :verified,
    role: i == 0 ? :admin : :normal,
    global_stock_threshold: global_stock_threshold
  )

  # Create profile for the user
  profile_name = i == 0 ? "Tolase" : Faker::Name.name
  Profile.create!(
    user: user,
    name: profile_name
  )

  users << user
end

# Create eCommerce-related categories
categories = ["Electronics", "Clothing", "Home & Kitchen", "Books", "Toys", 
             "Sports", "Beauty", "Health", "Grocery", "Automotive"]
categories.each do |category_name|
  Category.create!(
    name: category_name,
    user: users.first,
    description: Faker::Lorem.sentence
  )
end

# Create 100 items associated with the first user
100.times do
  item = Item.create!(
    name: Faker::Commerce.product_name,
    description: Faker::Lorem.sentence,
    quantity: rand(0..100),
    category: Category.all.sample,
    user: users.first,
    stock_threshold: rand(0..20)
  )
end

# Create inventory actions
items = Item.all

# First perform "remove" actions
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

# Then perform "add" actions with admin
items.each do |item|
  amount = rand(10..50)
  item.modify_quantity(
    "add",
    amount,
    users.first,
    "Added #{amount} units of #{item.name}"
  )
end

# Force some items to be low stock (20% of total items)
low_stock_percentage = 0.2
low_stock_count = (Item.count * low_stock_percentage).ceil
low_stock_items = Item.all.sample(low_stock_count)

low_stock_items.each do |item|
  effective_threshold = [item.stock_threshold, item.user.global_stock_threshold].max
  
  # Ensure valid quantity range
  max_low_quantity = [effective_threshold - 1, 0].max
  new_quantity = rand(0..max_low_quantity)
  
  item.update_columns(quantity: new_quantity)
end

# Final update of all low_stock statuses
Item.find_each do |item|
  effective_threshold = [item.stock_threshold, item.user.global_stock_threshold].max
  current_low_stock = item.quantity <= effective_threshold
  item.update_columns(low_stock: current_low_stock)
end

# Re-enable the after_commit callback
Item.set_callback(:commit, :after, :update_stock_status)

puts "Seeding completed successfully!"
puts "#{Item.low_stock.count} items marked as low stock"