source "https://rubygems.org"

gem "rails",                                "8.0.1"
gem "active_storage_validations",           "1.4.0"
gem "bcrypt",                               "3.1.20"
gem "bootsnap",                             "1.18.4", require: false
gem "faker",                                "3.5.1"
gem "image_processing",                     "1.14.0"
gem "importmap-rails",                      "2.1.0"
gem "jbuilder",                              "2.13.0"
gem "kamal", require: false
gem "noticed",                              "2.6"
gem "pagy",                                 "9.3.3"
gem "propshaft"
gem "puma",                                 "6.6.0"
gem "ransack",                              "4.3.0"
gem "solid_cache"
gem "solid_cable"
gem "solid_queue"
gem "sqlite3",                              "2.5.0"
gem "stimulus-rails",                       "1.3.4"
gem "tailwindcss-rails", "~> 4.0"
gem "tailwindcss-ruby", "~> 4.0" # only necessary with tailwindcss-rails <= 3.3.0
gem "thruster", require: false
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "letter_opener_web",                  "3.0"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end