class Account < ApplicationRecord
  include Rodauth::Rails.model
  enum :status, { unverified: 1, verified: 2, closed: 3 }
  enum :role, { Normal: 1, Admin: 2 }

  has_one :profile

  has_many :categories, dependent: :destroy
  has_many :items, dependent: :destroy
end
