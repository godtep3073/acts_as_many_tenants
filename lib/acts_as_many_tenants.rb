module ActsAsManyTenants
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_many_tenants(association = :accounts, options = {})
      options.reverse_merge!(through: false, required: false, immutable: true, auto: true, class_name: nil)

      if options[:through] && options[:required]
        raise(ArgumentError, ':required cannot be used together with :through [ActsAsManyTenants]')
      end

      has_and_belongs_to_many association

      # e.g. account_ids
      singular_ids = "#{association.to_s.singularize}_ids"

      reflection = reflect_on_association(association)

      if options[:through]
        reflection = reflect_on_association(options[:through])
        source_reflection = reflection.source_reflection
        through_reflection = reflection.through_reflection
      end

      if options[:auto]
        before_validation proc { |m|
          if ActsAsTenant.current_tenant.blank? && m.send(association.to_sym).present?
            nil
          else
            m.send "#{association}=".to_sym, [ActsAsTenant.current_tenant]
          end
        }, on: :create
      end

      if options[:immutable]
        define_method "#{singular_ids}=" do |ids|
          raise "#{association} is immutable! [ActsAsManyTenants]" unless new_record?
          super(ids)
        end

        define_method "#{association}=" do |models|
          raise "#{association} is immutable! [ActsAsManyTenants]" unless new_record?
          models.compact!
          super(models)
        end

        # TODO: override these methods aswell
        # associations.<<(model), associations.delete(model), associations.clear, associations.build, associations.create
      end

      validates_presence_of singular_ids if options[:required]

      # set the default_scope to scope to current tenant
      # using EXISTS queries here,
      # not using joins() since that would give us ReadOnly records
      if options[:through]
        default_scope lambda {
          if ActsAsTenant.current_tenant
            if Rails::VERSION::MAJOR >= 4
              where("EXISTS (SELECT 1 FROM #{through_reflection.table_name} WHERE #{through_reflection.table_name}.#{through_reflection.foreign_key} = #{table_name}.id AND #{through_reflection.table_name}.#{source_reflection.association_foreign_key} = ?)", ActsAsTenant.current_tenant.id)
            else
              where("EXISTS (SELECT 1 FROM #{source_reflection.options[:join_table]} WHERE #{source_reflection.options[:join_table]}.#{source_reflection.foreign_key} = #{table_name}.#{through_reflection.foreign_key} AND #{source_reflection.options[:join_table]}.#{source_reflection.association_foreign_key} = ?)", ActsAsTenant.current_tenant.id)
            end
          elsif Rails::VERSION::MAJOR >= 5
            where(false)
          end
        }
      else
        default_scope lambda {
          if ActsAsTenant.current_tenant
            if Rails::VERSION::MAJOR >= 4
              where("EXISTS (SELECT 1 FROM #{reflection.join_table} WHERE #{reflection.join_table}.#{reflection.foreign_key} = #{table_name}.id AND #{reflection.join_table}.#{reflection.association_foreign_key} = ?)", ActsAsTenant.current_tenant.id)
            else
              where("EXISTS (SELECT 1 FROM #{reflection.options[:join_table]} WHERE #{reflection.options[:join_table]}.#{reflection.foreign_key} = #{table_name}.id AND #{reflection.options[:join_table]}.#{reflection.association_foreign_key} = ?)", ActsAsTenant.current_tenant.id)
            end
          elsif Rails::VERSION::MAJOR >= 5
            where(false)
          end
        }
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActsAsManyTenants)
