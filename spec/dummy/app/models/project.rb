class Project < ApplicationRecord
  # attr_accessible :name
  has_many :tasks
  acts_as_many_tenants :accounts
end
