class Thing < ApplicationRecord
  # attr_accessible :name
  acts_as_many_tenants :accounts, :auto => false, :required => true
end
