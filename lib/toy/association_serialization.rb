module Toy
  module AssociationSerialization
    extend ActiveSupport::Concern
    include Serialization

    def serializable_hash(options = nil)
      options ||= {}
      super.tap { |hash|
        serializable_add_includes(options) do |association, records, opts|
          hash[association] = records.is_a?(Enumerable) ?
            records.map { |r| r.serializable_hash(opts) } :
            records.serializable_hash(opts)
        end
      }
    end

    private

    # Add associations specified via the <tt>:includes</tt> option.
    # Expects a block that takes as arguments:
    #   +association+ - name of the association
    #   +records+     - the association record(s) to be serialized
    #   +opts+        - options for the association records
    def serializable_add_includes(options = {})
      return unless include_associations = options.delete(:include)

      base_only_or_except = { :except => options[:except],
                              :only => options[:only] }

      include_has_options = include_associations.is_a?(Hash)
      associations = include_has_options ? include_associations.keys : Array.wrap(include_associations)

      for association in associations
        records = if self.class.list?(association)
          send(association).to_a
        elsif self.class.reference?(association) || self.class.parent_reference?(association)
          send(association)
        end

        unless records.nil?
          association_options = include_has_options ? include_associations[association] : base_only_or_except
          opts = options.merge(association_options)
          yield(association, records, opts)
        end
      end

      options[:include] = include_associations
    end
  end
end
