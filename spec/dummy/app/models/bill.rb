class Bill < ApplicationRecord
  # attr_accessible :name
  acts_as_many_tenants :accounts, :auto => false
end
