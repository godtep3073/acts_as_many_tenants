class User < ApplicationRecord
  # attr_accessible :name
  acts_as_many_tenants :accounts, :immutable => false
end
