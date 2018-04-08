# Acts As Many Tenants

As an extension for [acts_as_tenant](http://github.com/ErwinM/acts_as_tenant) this gem allows for a model to belong to many tenants.

acts_as_many_tenants sets up a `has_and_belongs_to_many` relationship to a tenant model and introduces a `default_scope` that checks for the existence of an association to `ActsAsTenant.current_tenant`.

## Usage

Add the following line to your model

``acts_as_many_tenants``

You can specify the name of the tenant model as an attribute (defaults to `Account`).

``acts_as_many_tenants(:accounts)``

# \*\*\* Options: through, is broken in Rails 5 \*\*\*

You can also use a `has_many :through` relation for tenants.
For example a `Task` may belong to a `Project` and relate to many accounts through its project:

``acts_as_many_tenants(:accounts, :through => :project)``

You can provide a class_name (useful when using namespaces):

``acts_as_many_tenants(:accounts, :through => :project, :class_name => 'Foo::Project)``

Newly created models get the current_tenant assigned if you haven’t assigned any tenants yourself.  
Pass `:auto => false` to prevent this behaviour:

``acts_as_many_tenants(:accounts, :auto => false)``

Add `:required => true` in order to validate the presence of an associated tenant.

``acts_as_many_tenants(:accounts, :auto => false, :required => true)``

## Installation

Add the following line to your Gemfile

``gem 'acts_as_many_tenants', :git => 'git://github.com/laurens/acts_as_many_tenants.git'``

and run

``bundle install``

## TODO

Make associations immutable in order to align with `acts_as_tenant`.
At the moment only the `association=[model]` and `association_ids=ids` methods take care of that. Missing implementation for
the other association writers `associations.<<(model)`, `associations.delete(model)`, `associations.clear`, `associations.build`, `associations.create`.

Pull Requests welcome!

## Author & Credits

acts_as_many_tenants is written by Laurens Nienhaus as an extension for and inspired by [acts_as_tenant](http://github.com/ErwinM/acts_as_tenant).

## License

Copyright (c) 2013 Laurens Nienhaus, released under the MIT license
