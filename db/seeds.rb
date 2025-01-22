# Clear existing data
Account.destroy_all
Category.destroy_all
Item.destroy_all
InventoryAction.destroy_all

# Helper method to generate random email
def generate_email(name)
  "#{name.downcase.gsub(/\s+/, '.')}@test.com"
end

# Create 10 verified accounts
accounts = []
10.times do |i|
  email = i == 0 ? "tolase@test.com" : generate_email(Faker::Name.name)
  password = i == 0 ? "foofoofoo" : "password"
  global_stock_threshold = i == 0 ? 10 : rand(5..20)

  account = Account.create!(
    email: email,
    password_hash: BCrypt::Password.create(password),
    status: :verified, # Verified status
    role: i == 0 ? :admin : :normal, # First account is admin, others are normal users
    global_stock_threshold: global_stock_threshold
  )

  # Create profile for the account
  profile_name = i == 0 ? "Tolase" : Faker::Name.name
  Profile.create!(
    account: account,
    name: profile_name
  )

  accounts << account
end

# Create eCommerce-related categories
categories = ["Electronics", "Clothing", "Home & Kitchen", "Books", "Toys", "Sports", "Beauty", "Health", "Grocery", "Automotive"]
categories.each do |category_name|
  Category.create!(
    name: category_name,
    account: accounts.first, # Associate with the first account
    description: Faker::Lorem.sentence
  )
end

# Create 100 items associated with the first account
100.times do
  Item.create!(
    name: Faker::Commerce.product_name,
    description: Faker::Lorem.sentence,
    quantity: rand(0..100),
    category: Category.all.sample,
    account: accounts.first,
    stock_threshold: rand(0..20)
  )
end

# Create inventory actions
items = Item.all
accounts.each do |account|
  # Each account performs "remove" actions on random items
  rand(5..15).times do
    item = items.sample
    item.modify_quantity(
      "remove",
      rand(1..10),
      account,
      "Removed #{rand(1..10)} units of #{item.name}"
    )
  end
end

# Admin (first account) performs "add" actions on all items
items.each do |item|
  item.modify_quantity(
    "add",
    rand(10..50),
    accounts.first,
    "Added #{rand(10..50)} units of #{item.name}"
  )
end

puts "Seeding completed successfully!"