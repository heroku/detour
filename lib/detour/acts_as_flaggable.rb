module Detour::ActsAsFlaggable
  # Sets up ActiveRecord associations for the including class, and includes
  # {Detour::Flaggable} in the class.
  #
  # @example
  #   class User < ActiveRecord::Base
  #     acts_as_taggable find_by: :email
  #   end
  #
  # @option options [Symbol] :find_by The field to find the record by when
  #   running rake tasks. Defaults to :id.
  def acts_as_flaggable(options = {})
    Detour::Feature.class_eval <<-EOF
      has_one :#{table_name}_percentage_flag,
        class_name: "Detour::PercentageFlag",
        inverse_of: :feature,
        dependent:  :destroy,
        conditions: { flaggable_type: "#{self}" }

      attr_accessible :#{table_name}_percentage_flag_attributes

      accepts_nested_attributes_for :#{table_name}_percentage_flag,
        update_only: true,
        reject_if: proc { |attrs| attrs[:percentage].blank? }

      has_many :#{table_name}_group_flags,
        class_name: "Detour::GroupFlag",
        inverse_of: :feature,
        dependent: :destroy,
        conditions: { flaggable_type: "#{self}" }

      attr_accessible :#{table_name}_group_flags_attributes
      accepts_nested_attributes_for :#{table_name}_group_flags, allow_destroy: true

      has_many :#{table_name}_database_group_flags,
        class_name: "Detour::DatabaseGroupFlag",
        inverse_of: :feature,
        dependent: :destroy,
        conditions: { flaggable_type: "#{self}" }

      attr_accessible :#{table_name}_database_group_flags_attributes
      accepts_nested_attributes_for :#{table_name}_database_group_flags, allow_destroy: true

      has_many :#{table_name}_flag_ins,
        class_name: "Detour::FlagInFlag",
        inverse_of: :feature,
        dependent:  :destroy,
        conditions: { flaggable_type: "#{self}" }

      has_many :#{table_name}_opt_outs,
        class_name: "Detour::OptOutFlag",
        inverse_of: :feature,
        dependent:  :destroy,
        conditions: { flaggable_type: "#{self}" }
    EOF

    class_eval do
      @detour_flaggable_find_by = :id

      has_many :flag_in_flags,
        as: :flaggable,
        class_name: "Detour::FlagInFlag"

      has_many :opt_out_flags,
        as: :flaggable,
        class_name: "Detour::OptOutFlag"

      has_many :features,
        through: :flag_in_flags,
        class_name: "Detour::Feature"

      if options[:find_by]
        @detour_flaggable_find_by = options[:find_by]
      end

      def self.detour_flaggable_find_by
        @detour_flaggable_find_by
      end

      extend  Detour::Flaggable::ClassMethods
      include Detour::Flaggable
    end
  end
end
