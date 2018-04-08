class Task < ApplicationRecord
  # attr_accessible :name
  belongs_to :project
  acts_as_many_tenants :accounts, :through => :project, :class_name => 'Project'
end
